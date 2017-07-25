require 'samanage'

describe Samanage::Api do
	context 'Hardware' do
		describe 'API Functions' do
			before(:each) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@controller = Samanage::Api.new(token: TOKEN)
			end
			it 'get_hardwares: it returns API call of hardwares' do
				api_call = @controller.get_hardwares
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_hardwares: collects array of hardwares' do
				hardwares = @controller.collect_hardwares
				hardware_count = @controller.get_hardwares[:total_count]
				expect(hardwares).to be_an(Array)
				expect(hardwares.size).to eq(hardware_count)
			end
			it 'create_hardware(payload: json): creates a hardware' do
				hardware_name = "samanage-ruby-#{(rand*10**10).ceil}"
				serial_number = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:hardware => {
						:name => hardware_name,
						:bio => {:ssn => serial_number},
					}
				}
				hardware_create = @controller.create_hardware(payload: json.to_json)

				expect(hardware_create[:data]['id']).to be_an(Integer)
				expect(hardware_create[:data]['name']).to eq(hardware_name)
				expect(hardware_create[:code]).to eq(201).or(200)
			end
			it 'create_hardware: fails if no serial' do
				hardware_name = "samanage-ruby-#{(rand*10**10).ceil}"
				json = {
					:hardware => {
						:name => hardware_name,
					}
				}
				expect{@controller.create_hardware(payload: json.to_json)}.to raise_error(Samanage::InvalidRequest)
			end
			it 'find_hardware: returns a hardware card by known id' do
				hardwares = @controller.collect_hardwares
				sample_id = hardwares.sample['id']
				hardware = @controller.find_hardware(id: sample_id)

				expect(hardware[:data]['id']).to eq(sample_id)  # id should match found hardware
				expect(hardware[:data]).to have_key('name')
				expect(hardware[:data]).to have_key('serial_number')
				expect(hardware[:data]).to have_key('id')
			end
			it 'find_hardware: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@controller.find_hardware(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found hardware
			end
			it 'update_hardware: update_hardware by id' do
				hardwares = @controller.collect_hardwares
				sample_id = hardwares.sample['id']
				new_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:hardware => {
						:name => new_name
					}
				}
				hardware_update = @controller.update_hardware(payload: json.to_json, id: sample_id)
				expect(hardware_update[:data]["name"]).to eq(new_name)
				expect(hardware_update[:code]).to eq(200).or(201)
			end
		end
	end
end