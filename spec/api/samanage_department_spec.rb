require 'samanage'
require 'faker'
describe Samanage::Api do
  context 'department' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @departments = @samanage.departments
    end
    it 'get_users: it returns API call of departments' do
      api_call = @samanage.get_departments
      expect(api_call).to be_a(Hash)
      expect(api_call[:total_count]).to be_an(Integer)
      expect(api_call).to have_key(:response)
      expect(api_call).to have_key(:code)
    end
    it 'collects all departments' do
      department_count = @samanage.get_departments[:total_count]
      expect(@departments).to be_an(Array)
      expect(@departments.size).to eq(department_count)
    end
    it 'creates a department' do
      department_name = Faker::Book.title
      department_description = Faker::Book.author
      payload = {
        department: {
          name: department_name,
          description: department_description
        }
      }
      department_create = @samanage.create_department(payload: payload)

      expect(department_create[:data]['id']).to be_an(Integer)
      expect(department_create[:data]['name']).to eq(department_name)
      expect(department_create[:code]).to eq(201).or(200)
    end
    it 'deletes a valid department' do
      sample_department_id = @departments.sample.dig('id')
      department_delete = @samanage.delete_department(id: sample_department_id)
      expect(department_delete[:code]).to eq(200).or(201)
    end
    it 'fails to delete invalid department' do 
      invalid_department_id = 0
      expect{@samanage.delete_department(id: invalid_department_id)}.to raise_error(Samanage::NotFound)
    end
  end
end