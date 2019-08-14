# frozen_string_literal: true

require "samanage"

describe Samanage::Api do
  context "Other Assets" do
    describe "API Functions" do
      before(:all) do
          TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
          @samanage = Samanage::Api.new(token: TOKEN)
          @releases = @samanage.get_releases[:data]
          @users = @samanage.get_users[:data]
        end
      it "get_releases: it returns API call of releases" do
        api_call = @samanage.get_releases
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it "collect_releases: collects array of releases" do
        expect(@releases).to be_an(Array)
      end
      it "create_release(payload: json): creates a release" do
        7.times do |time|
          release_name = "samanage-ruby-#{(rand * 10**10).ceil}"
          json = {
            release: {
              name: release_name,
              requester: { email: @users.sample["email"] },
              state: "Open"
            }
          }

          release_create = @samanage.create_release(payload: json)
          expect(release_create[:data]["id"]).to be_an(Integer)
          expect(release_create[:data]["name"]).to eq(release_name)
          expect(release_create[:code]).to eq(200).or(201)
        end
      end
      it "create_release: fails if wrong fields" do
        release_name = "samanage-ruby-#{(rand * 10**10).ceil}"
        json = {
          release: {
            name: release_name,
          }
        }
        expect { @samanage.create_release(payload: json) }.to raise_error(Samanage::InvalidRequest)
      end

      it "find_release: returns an release card by known id" do
        sample_id = @releases.sample["id"]
        release = @samanage.find_release(id: sample_id)

        expect(release[:data]["id"]).to eq(sample_id)  # id should match found release
        expect(release[:data]).to have_key("name")
        expect(release[:data]).to have_key("id")
      end
      it "find_release: returns nothing for an invalid id" do
        sample_id = (0..10).entries.sample
        expect { @samanage.find_release(id: sample_id) }.to raise_error(Samanage::NotFound)  # id should match found release
      end
      it "update_release: update_release by id" do
        sample_id = @releases.sample["id"]
        new_name = (0...50).map { ("a".."z").to_a[rand(26)] }.join
        json = {
          release: {
            name: new_name
          }
        }
        release_update = @samanage.update_release(payload: json, id: sample_id)
        expect(release_update[:data]["name"]).to eq(new_name)
        expect(release_update[:code]).to eq(200).or(201)
      end
      it "deletes a valid release" do
        sample_release_id = @releases.sample["id"]
        release_delete = @samanage.delete_release(id: sample_release_id)
        expect(release_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
