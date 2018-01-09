require 'samanage'

describe Samanage::Api do
	context 'Other Assets' do
		describe 'API Functions' do
		before(:all) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
			@other_assets = @controller.other_assets
		end
			it 'get_other_assets: it returns API call of other_assets' do
				api_call = @controller.get_other_assets
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_other_assets: collects array of other_assets' do
				expect(@other_assets).to be_an(Array)
			end
			it 'create_other_asset(payload: json): creates a other_asset' do
				other_asset_name = "samanage-ruby-#{(rand*10**10).ceil}"
				json = {
					:other_asset => {
						:name => other_asset_name,
						:manufacturer => 'Samanage',
						:asset_type => {:name => "Asset"},
						:status => {:name => "Operational"}
					}
				}

				other_asset_create = @controller.create_other_asset(payload: json)
				expect(other_asset_create[:data]['id']).to be_an(Integer)
				expect(other_asset_create[:data]['name']).to eq(other_asset_name)
				expect(other_asset_create[:code]).to eq(200).or(201)
			end
			it 'create_other_asset: fails if wrong fields' do
				other_asset_name = "samanage-ruby-#{(rand*10**10).ceil}"
				json = {
					:other_asset => {
						:name => other_asset_name,
						:manufacturer => 'Samanage',
						:asset_type => {:name => "Asset"},
						:status => {:name => "Operational"}
					}
				}
				json[:other_asset].delete(json[:other_asset].keys.sample) # Delete random sample from the examples above
				expect{@controller.create_other_asset(payload: json)}.to raise_error(Samanage::InvalidRequest)
			end

			it 'find_other_asset: returns an other_asset card by known id' do
				sample_id = @other_assets.sample['id']

				other_asset = @controller.find_other_asset(id: sample_id)

				expect(other_asset[:data]['id']).to eq(sample_id)  # id should match found other_asset
				expect(other_asset[:data]).to have_key('name')
				expect(other_asset[:data]).to have_key('serial_number')
				expect(other_asset[:data]).to have_key('id')
			end
			it 'find_other_asset: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@controller.find_other_asset(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found other_asset
			end
			it 'update_other_asset: update_other_asset by id' do
				sample_id = @other_assets.sample['id']
				new_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:other_asset => {
						:name => new_name
					}
				}
				other_asset_update = @controller.update_other_asset(payload: json, id: sample_id)
				expect(other_asset_update[:data]["name"]).to eq(new_name)
				expect(other_asset_update[:code]).to eq(200).or(201)
			end
		end
	end
end