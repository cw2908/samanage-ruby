require 'samanage'
describe Samanage::Api do
  context 'solution' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @solutions = @samanage.solutions
    end
    it 'get_users: it returns API call of users' do
      api_call = @samanage.get_solutions
      expect(api_call).to be_a(Hash)
      expect(api_call[:total_count]).to be_an(Integer)
      expect(api_call).to have_key(:response)
      expect(api_call).to have_key(:code)
    end
    it 'collects all solutions' do
      solutions = @solutions
      solution_count = @samanage.get_solutions[:total_count]
      expect(solutions).to be_an(Array)
      expect(solutions.size).to eq(solution_count)
    end
    it 'creates a solution' do
      solution_name = Faker::Music.album
      solution_description = Faker::Music.band
      payload = {
        solution: {
          name: solution_name,
          description: solution_description
        }
      }
      solution_create = @samanage.create_solution(payload: payload)

      expect(solution_create[:data]['id']).to be_an(Integer)
      expect(solution_create[:data]['name']).to eq(solution_name)
      expect(solution_create[:code]).to eq(200)
    end
    it 'updates a valid solution' do
      sample_solution_id = @solutions.sample['id']
      new_description = Faker::Movie.quote
      payload = {solution: {description: new_description}}
      solution_update = @samanage.update_solution(id: sample_solution_id, payload: payload)
      
      expect(new_description).to eq(solution_update.dig(:data,'description'))
      expect(solution_update[:code]).to eq(200)
    end
  end
end