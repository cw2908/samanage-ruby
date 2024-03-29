# frozen_string_literal: true

require "samanage"
require "faker"
describe Samanage::Api do
  context "Incidents" do
    describe "API Functions" do
      before(:all) do
        TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
        @samanage = Samanage::Api.new(token: TOKEN)
        @incidents = @samanage.incidents
        @users = @samanage.users
        @incidents_with_archives = @samanage.incidents(options: { audit_archives: true, layout: "long", verbose: true })
      end
      it "get_incidents: it returns API call of incidents" do
        api_call = @samanage.get_incidents
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it "collect_incidents: collects array of incidents" do
        incident_count = @samanage.get_incidents[:total_count]
        @incidents = @samanage.incidents
        expect(@incidents).to be_an(Array)
        expect(@incidents.size).to eq(incident_count)
      end
      it "create_incident(payload: json): creates a incident" do
          users_email = @samanage.collect_users.sample["email"]
          incident_name = [
            Faker::Movies::StarWars.specie,
            Faker::Movies::StarWars.planet,
            Faker::Movies::StarWars.droid
          ].shuffle.join(" ")
          json = {
            incident: {
              requester: { email: users_email },
              name: incident_name,
              description: Faker::Movies::StarWars.quote
            }
          }
          incident_create = @samanage.create_incident(payload: json)

          expect(incident_create[:data]["id"]).to be_an(Integer)
          expect(incident_create[:data]["name"]).to eq(incident_name)
          expect(incident_create[:code]).to eq(200).or(201)
      end
      it "create_incident: fails if no name/title" do
        users_email = @users.sample["email"]
        json = {
          incident: {
            requester: { email: users_email },
            description: Faker::Movies::StarWars.quote
          }
        }
        expect { @samanage.create_incident(payload: json) }.to raise_error(Samanage::InvalidRequest)
      end
      it "find_incident: returns a incident card by known id" do
        sample_id = @incidents.sample["id"]
        incident = @samanage.find_incident(id: sample_id)

        expect(incident[:data]["id"]).to eq(sample_id) # id should match found incident
        expect(incident[:data]).to have_key("name")
        expect(incident[:data]).to have_key("requester")
        expect(incident[:data]).to have_key("id")
      end
      it "find_incident: returns more keys with layout=long" do
        sample_id = @incidents.sample["id"]
        layout_regular_incident = @samanage.find_incident(id: sample_id)
        layout_long_incident = @samanage.find_incident(id: sample_id, options: { layout: "long" })

        expect(layout_long_incident[:data]["id"]).to eq(sample_id) # id should match found incident
        expect(layout_long_incident[:data].keys.size).to be > layout_regular_incident.keys.size
        expect(layout_long_incident[:data].keys - layout_regular_incident[:data].keys).to_not be([])
      end
      it "find_incident: returns nothing for an invalid id" do
        sample_id = (0..10).entries.sample
        # id should match found incident
        expect {
          @samanage.find_incident(id: sample_id)
        }.to raise_error(Samanage::NotFound)
      end
      it "update_incident: update_incident by id" do
        sample_incident = @incidents.reject { |i| %w[Closed Resolved].include? i["state"] }.sample
        sample_id = sample_incident["id"]
        description = [Faker::String.random, Faker::TvShows::Seinfeld.quote, Faker::Lorem.paragraph].sample
        incident_json = {
          incident: {
            description: description
          }
        }
        incident_update = @samanage.update_incident(payload: incident_json, id: sample_id)
        expect(incident_update[:data]["description"]).to eq(description)
        expect(incident_update[:code]).to eq(200).or(201)
      end
      it 'finds more data for option[:layout] = "long"' do
        full_layout_incident_keys = @samanage.incidents(options: { layout: "long" }).first.keys
        basic_incident_keys = @samanage.incidents.sample.keys
        expect(basic_incident_keys.size).to be < full_layout_incident_keys.size
      end
      it "finds more audit archives for option[:audit_archives] = true" do
        incident_keys = @incidents_with_archives.sample.keys
        expect(incident_keys).to include
        "audits"
      end
      it 'finds audit archives for options: {audit_archives: true, layout: "long"}' do
        full_incident_keys = @incidents_with_archives.first.keys
        basic_incident_keys = @incidents.sample.keys
        expect(basic_incident_keys.size).to be < full_incident_keys.size
        expect(full_incident_keys).to include("audits")
      end
      it "deletes a valid incident" do
        sample_incident_id = @incidents.sample["id"]
        incident_delete = @samanage.delete_incident(id: sample_incident_id)
        expect(incident_delete[:code]).to eq(200).or(201)
      end
      it "Sends an email if add_callbacks=true in params" do
        sample_id = @samanage.get_incidents[:data].sample["id"]
        audits_req = @samanage.find_incident(id: sample_id, options: { layout: "long" })
        user_email = @users.find { |u| u.dig("role", "name") == "Administrator" }.dig("email")
        initial_email_audits = audits_req.dig(:data, "audits")
          .select { |audit| audit["message"].match(/was sent./) }
          .count
        incident_json = {
          incident: {
            state: "New",
            # Must to configure email notifications for due date change
            due_at: Date.new(2019, rand(1..11), rand(1..27)),
            assignee: { email: user_email }
          }
        }

        @samanage.update_incident(payload: incident_json, id: sample_id, options: { add_callbacks: true })
        sleep 5 # Wait for email to send
        final_audits_req = @samanage.find_incident(id: sample_id, options: { layout: "long" })
        final_email_audits = final_audits_req.dig(:data, "audits")
          .select { |audit| audit["message"].match(/was sent./) }
          .count
        expect(initial_email_audits).to be < final_email_audits
      end
    end
  end
end
