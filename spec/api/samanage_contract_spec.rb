require 'samanage'

describe Samanage::Api do
  context 'Contract' do 
    describe 'API Fucntions' do
      before(:all) do 
        TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
				@samanage = Samanage::Api.new(token: TOKEN)
				@contracts = @samanage.contracts
      end
      it 'get_contracts: it returns API call of contracts' do
				api_call = @samanage.get_contracts
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_contracts: collects array of contracts' do
				contract_count = @samanage.get_contracts[:total_count]
				expect(@contracts).to be_an(Array)
				expect(@contracts.size).to eq(contract_count)
			end
			it 'create_contract(payload: json): creates a contract' do
				manufacturer_name = "samanage-ruby-#{(rand*10**10).ceil}"
				random_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					contract: {
						type: 'SoftwareLicense',
            manufacturer_name: 'Adobe',
            status: 'Active',
						name:  random_name,
					}
				}
				contract_create = @samanage.create_contract(payload: json)

				expect(contract_create[:data]['id']).to be_an(Integer)
				expect(contract_create[:data]['name']).to eq(random_name)
			end
			it 'create_contract: fails if no status' do
				contract_name = "samanage-ruby-#{(rand*10**10).ceil}"
				json = {
					:contract => {
						model: 'test',
						manufacturer_name: contract_name,
					}
				}
				expect{@samanage.create_contract(payload: json)}.to raise_error(Samanage::InvalidRequest)
			end
			it 'find_contract: returns a contract card by known id' do
				sample_id = @contracts.sample['id']
				contract = @samanage.find_contract(id: sample_id)

				expect(contract[:data]['id']).to eq(sample_id)  # id should match found contract
				expect(contract[:data]).to have_key('manufacturer_name')
				expect(contract[:data]).to have_key('name')
				expect(contract[:data]).to have_key('id')
			end
			it 'find_contract: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@samanage.find_contract(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found contract
			end
			it 'update_contract: update_contract by id' do
				sample_id = @contracts.sample['id']
				new_name = (0...50).map {('a'..'z').to_a[rand(26)] }.join
				json = {
					contract: {
						manufacturer_name: new_name
					}
				}
				contract_update = @samanage.update_contract(payload: json, id: sample_id)
				expect(contract_update[:data]["manufacturer_name"]).to eq(new_name)
				expect(contract_update[:code]).to eq(200).or(201)
      end
      it 'adds an item to a contract by id' do
        sample_id = @contracts.sample['id']
        item = {
          item: {
            name: "name",
            version:" 123",
            qty: "2",
            tag: "tag",
          }
        }
        add_item = @samanage.add_item_to_contract(id: sample_id, payload: item)
        expect(add_item[:code]).to eq(200).or(201)
			end
			it 'deletes a valid contract' do
        sample_contract_id = @contracts.sample['id']
        contract_delete = @samanage.delete_contract(id: sample_contract_id)
        expect(contract_delete[:code]).to eq(200).or(201)
      end
      it 'fails to delete invalid contract' do 
				invalid_contract_id = 01
				abc = @samanage.delete_contract(id: invalid_contract_id)
				# expect{@samanage.delete_contract(id: invalid_contract_id)}.to raise_error(Samanage::NotFound)
      end
		end
	end
end