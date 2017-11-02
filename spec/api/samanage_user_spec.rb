require 'samanage'

describe Samanage::Api do
	context 'Users' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
		describe 'API Functions' do
			it 'get_users: it returns API call of users' do
				api_call = @controller.get_users
				expect(api_call).to be_a(Hash)
				expect(api_call[:total_count]).to be_an(Integer)
				expect(api_call).to have_key(:response)
				expect(api_call).to have_key(:code)
			end
			it 'collect_users: collects array of users' do
				users = @controller.collect_users
				user_count = @controller.get_users[:total_count]
				expect(users).to be_an(Array)
				expect(users.size).to eq(user_count)
			end
			it 'create_user(payload: json): creates a user' do
				user_name = "samanage-ruby-#{(rand*10**10).ceil}"
				email = user_name + "@samanage.com"
				json = {
					:user => {
						:name => user_name,
						:email => email,
					}
				}
				user_create = @controller.create_user(payload: json.to_json)
				expect(user_create[:data]['email']).to eq(email)
				expect(user_create[:data]['id']).to be_an(Integer)
				expect(user_create[:data]['name']).to eq(user_name)
				expect(user_create[:code]).to eq(200).or(201)
			end
			it 'create_user: fails if no email' do
				user_name = "samanage-ruby-#{(rand*10**(rand(10))).ceil}"
				json = {
					:user => {
            :name => user_name,
					}
				}
				expect{@controller.create_user(payload: json.to_json)}.to raise_error(Samanage::InvalidRequest)
			end
			it 'find_user: returns a user card by known id' do
				users = @controller.collect_users
				sample_id = users.sample['id']
				user = @controller.find_user(id: sample_id)
				expect(user[:data]['id']).to eq(sample_id)  # id should match found user
				expect(user[:data]).to have_key('email')
				expect(user[:data]).to have_key('name')
			end


			it 'find_user: returns nothing for an invalid id' do
				sample_id = (0..10).entries.sample
				expect{@controller.find_user(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found user
			end

			it 'finds_user_id_by_email' do
				users = @controller.collect_users
				sample_user = users.sample
				sample_email = sample_user['email']
				sample_email = sample_user['id']
				found_id = @controller.find_user_id_by_email(email: sample_email)
				expect(sample_email).to not_be(nil)
				expect(sample_email).to eq(found_id)
			end

			it 'update_user: update_user by id' do
				users = @controller.collect_users
				sample_id = users.sample['id']
				new_name = (0...25).map { ('a'..'z').to_a[rand(26)] }.join
				json = {
					:user => {
						:name => new_name
					}
				}
				user_update = @controller.update_user(payload: json.to_json, id: sample_id)
				expect(user_update[:data]["name"]).to eq(new_name)
				expect(user_update[:code]).to eq(200).or(201)
			end
		end
	end
end