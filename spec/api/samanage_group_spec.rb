require 'samanage'
describe Samanage::Api do
	context 'group' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
		it 'get_users: it returns API call of users' do
			api_call = @controller.get_groups
			expect(api_call).to be_a(Hash)
			expect(api_call[:total_count]).to be_an(Integer)
			expect(api_call).to have_key(:response)
			expect(api_call).to have_key(:code)
		end
		it 'collects all groups' do
			groups = @controller.collect_groups
			group_count = @controller.get_groups[:total_count]
			expect(groups).to be_an(Array)
			expect(groups.size).to eq(group_count)
		end
		it 'find_group: returns a group card by known id' do
			groups = @controller.collect_groups
			sample_id = groups.sample['id']
			group = @controller.find_group(id: sample_id)
			expect(group[:data]['id']).to eq(sample_id)  # id should match found group
			expect(group[:data]).to have_key('name')
		end
		it 'creates a group' do
			group_name = "Group Name #{(rand*10**4).ceil}"
			group_description = "Description #{(rand*10**4).ceil}"
			payload = {
				group: {
					name: group_name,
					description: group_description
				}
			}
			group_create = @controller.create_group(payload: payload)

			expect(group_create[:data]['id']).to be_an(Integer)
			expect(group_create[:data]['name']).to eq(group_name)
			expect(group_create[:code]).to eq(200).or(201)
		end

		it 'finds a group by name' do
			group = @controller.collect_groups.sample
			group_name = group['name']
			group_id = group['id']
			found_group_id = @controller.find_group_id_by_name(group: group_name)

			expect(group_id).to eq(found_group_id)
		end
		it 'returns nil for finding invalid group by name' do
			group_name = "Invalid-#{rand(100)*100}"
			found_group_id = @controller.find_group_id_by_name(group: group_name)
			expect(found_group_id).to be(nil)
		end
		it 'adds member to group' do
			random_group_id = @controller.collect_groups.sample['id']
			random_user_email = @controller.collect_users.sample['email']

			add_user_to_group = @controller.add_member_to_group(email: random_user_email, group_id: random_group_id)
			expect(add_user_to_group[:code]).to eq(200).or(201)
		end
	end
end