require 'samanage'
require 'faker'
describe Samanage::Api do
  context 'problems' do
    describe 'API Functions' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @problems = @samanage.problems
      @users = @samanage.get_users[:data]
    end
      it 'get_problems: it returns API call of problems' do
        api_call = @samanage.get_problems
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it 'collect_problems: collects array of problems' do
        problem_count = @samanage.get_problems[:total_count]
        @problems = @samanage.problems
        expect(@problems).to be_an(Array)
        expect(@problems.size).to eq(problem_count)
      end
      it 'create_problem(payload: json): creates a problem' do
        users_email = @samanage.collect_users.sample['email']
        problem_name = Faker::Book.title
        json = {
          problem: {
            requester: {email: users_email},
            name: problem_name,
            state: 'Open',
            priority: 'Low',
            description: "Description"
          }
        }
        problem_create = @samanage.create_problem(payload: json)

        expect(problem_create[:data]['id']).to be_an(Integer)
        expect(problem_create[:data]['name']).to eq(problem_name)
        expect(problem_create[:code]).to eq(200).or(201)
      end
      it 'create_problem: fails if no name/title' do
        users_email = @users.sample['email']
        json = {
          :problem => {
            :requester => {:email => users_email},
            :description => "Description"
          }
        }
        expect{@samanage.create_problem(payload: json)}.to raise_error(Samanage::InvalidRequest)
      end
      it 'find_problem: returns a problem card by known id' do
        sample_id = @problems.sample['id']
        problem = @samanage.find_problem(id: sample_id)

        expect(problem[:data]['id']).to eq(sample_id)  # id should match found problem
        expect(problem[:data]).to have_key('name')
        expect(problem[:data]).to have_key('requester')
        expect(problem[:data]).to have_key('id')
      end
      it 'find_problem: returns more keys with layout=long' do
        sample_id = @problems.sample['id']
        layout_regular_problem = @samanage.find_problem(id: sample_id)
        layout_long_problem = @samanage.find_problem(id: sample_id, options: {layout: 'long'})

        expect(layout_long_problem[:data]['id']).to eq(sample_id)  # id should match found problem
        expect(layout_long_problem[:data].keys.size).to be > (layout_regular_problem.keys.size)
        expect(layout_long_problem[:data].keys - layout_regular_problem[:data].keys).to_not be([])
      end
      it 'find_problem: returns nothing for an invalid id' do
        sample_id = (0..10).entries.sample
        expect{@samanage.find_problem(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found problem
      end
      it 'update_problem: update_problem by id' do
        sample_problem = @problems.reject{|i| ['Closed','Resolved'].include? i['state']}.sample
        sample_id = sample_problem['id']
        description = (0...500).map { ('a'..'z').to_a[rand(26)] }.join
        problem_json = {
          :problem => {
            :description => description
          }
        }
        problem_update = @samanage.update_problem(payload: problem_json, id: sample_id)
        # expect(problem_update[:data]['description']).to eq(description) # problem bug #00044569
        expect(problem_update[:code]).to eq(200).or(201)
      end
      it 'finds more data for option[:layout] = "long"' do
        full_layout_problem_keys = @samanage.problems(options: {layout: 'long'}).first.keys
        basic_problem_keys = @samanage.problems.sample.keys
        expect(basic_problem_keys.size).to be < full_layout_problem_keys.size
      end
      it 'deletes a valid problem' do
        sample_problem_id = @problems.sample['id']
        problem_delete = @samanage.delete_problem(id: sample_problem_id)
        expect(problem_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
