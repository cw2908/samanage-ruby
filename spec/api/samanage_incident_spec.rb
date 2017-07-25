require 'samanage'

describe Samanage::Api do
	context 'Incidents' do
		describe 'API Functions' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
			it 'get_incidents: it returns API call of incidents' do
				api_call = @controller.get_incidents
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_incidents: collects array of incidents' do
				incidents = @controller.collect_incidents
				incident_count = @controller.get_incidents[:total_count]
				expect(incidents).to be_an(Array)
				expect(incidents.size).to eq(incident_count)
			end
			it 'create_incident(payload: json): creates a incident' do
				users_email = @controller.collect_users.sample['email']
				serial_number = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				incident_name = "Samanage Ruby Incident"
				json = {
					:incident => {
						:requester => {:email => users_email},
						:name => incident_name,
						:description => "Description"
					}
				}
				incident_create = @controller.create_incident(payload: json.to_json)

				expect(incident_create[:data]['id']).to be_an(Integer)
				expect(incident_create[:data]['name']).to eq(incident_name)
				expect(incident_create[:code]).to eq(200).or(201)
			end
			it 'create_incident: fails if no name/title' do
				users_email = @controller.collect_users.sample['email']
				json = {
					:incident => {
						:requester => {:email => users_email},
						:description => "Description"
					}
				}
				expect{@controller.create_incident(payload: json.to_json)}.to raise_error(Samanage::InvalidRequest)
			end
			it 'find_incident: returns a incident card by known id' do
				incidents = @controller.collect_incidents
				sample_id = incidents.sample['id']
				incident = @controller.find_incident(id: sample_id)

				expect(incident[:data]['id']).to eq(sample_id)  # id should match found incident
				expect(incident[:data]).to have_key('name')
				expect(incident[:data]).to have_key('requester')
				expect(incident[:data]).to have_key('id')
			end
			it 'find_incident: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@controller.find_incident(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found incident
			end
			it 'update_incident: update_incident by id' do
				incidents = @controller.collect_incidents
				sample_id = incidents.sample['id']
				new_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:incident => {
						:name => new_name
					}
				}
				incident_update = @controller.update_incident(payload: json.to_json, id: sample_id)
				expect(incident_update[:data]["name"]).to eq(new_name)
				expect(incident_update[:code]).to eq(200).or(201)
			end
		end
	end
end