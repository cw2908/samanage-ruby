require 'samanage'

describe Samanage::Api do
	context 'Mobile' do
		describe 'API Functions' do
			before(:each) do
				TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@controller = Samanage::Api.new(token: TOKEN)
			end
			it 'get_mobiles: it returns API call of mobiles' do
				api_call = @controller.get_mobiles
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_mobiles: collects array of mobiles' do
				mobiles = @controller.collect_mobiles
				mobile_count = @controller.get_mobiles[:total_count]
				expect(mobiles).to be_an(Array)
				expect(mobiles.size).to eq(mobile_count)
			end
			it 'create_mobile(payload: json): creates a mobile' do
				mobile_name = "samanage-ruby-#{(rand*10**10).ceil}"
				serial_number = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:mobile => {
						model: 'test',
						manufacturer: mobile_name,
						serial_number:  serial_number,
					}
				}
				mobile_create = @controller.create_mobile(payload: json)

				expect(mobile_create[:data]['id']).to be_an(Integer)
				expect(mobile_create[:data]['manufacturer']).to eq(mobile_name)
			end
			it 'create_mobile: fails if no serial' do
				mobile_name = "samanage-ruby-#{(rand*10**10).ceil}"
				json = {
					:mobile => {
						model: 'test',
						manufacturer: mobile_name,
					}
				}
				expect{@controller.create_mobile(payload: json)}.to raise_error(Samanage::InvalidRequest)
			end
			it 'find_mobile: returns a mobile card by known id' do
				mobiles = @controller.collect_mobiles
				sample_id = mobiles.sample['id']
				mobile = @controller.find_mobile(id: sample_id)

				expect(mobile[:data]['id']).to eq(sample_id)  # id should match found mobile
				expect(mobile[:data]).to have_key('manufacturer')
				expect(mobile[:data]).to have_key('serial_number')
				expect(mobile[:data]).to have_key('id')
			end
			it 'find_mobile: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@controller.find_mobile(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found mobile
			end
			it 'update_mobile: update_mobile by id' do
				mobiles = @controller.collect_mobiles
				sample_id = mobiles.sample['id']
				new_name = (0...50).map {('a'..'z').to_a[rand(26)] }.join
				json = {
					:mobile => {
						:manufacturer => new_name
					}
				}
				mobile_update = @controller.update_mobile(payload: json, id: sample_id)
				expect(mobile_update[:data]["manufacturer"]).to eq(new_name)
				expect(mobile_update[:code]).to eq(200).or(201)
			end
		end
	end
end