require 'samanage'
describe Samanage::Api do
	context 'department' do
		before(:all) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
			@departments = @controller.departments
		end
		it 'get_users: it returns API call of departments' do
			api_call = @controller.get_departments
			expect(api_call).to be_a(Hash)
			expect(api_call[:total_count]).to be_an(Integer)
			expect(api_call).to have_key(:response)
			expect(api_call).to have_key(:code)
		end
		it 'collects all departments' do
			department_count = @controller.get_departments[:total_count]
			expect(@departments).to be_an(Array)
			expect(@departments.size).to eq(department_count)
		end
		it 'creates a department' do
			department_name = "department ##{(rand*10**4).ceil}"
			department_location = "Location #{(rand*10**4).ceil}"
			department_description = "Location #{(rand*10**4).ceil}"
			payload = {
				department: {
					name: department_name,
					description: department_description
				}
			}
			department_create = @controller.create_department(payload: payload)

			expect(department_create[:data]['id']).to be_an(Integer)
			expect(department_create[:data]['name']).to eq(department_name)
			expect(department_create[:code]).to eq(201).or(200)
		end
	end
end