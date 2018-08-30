require 'samanage'
describe Samanage::Api do
  context 'changes' do
    describe 'API Functions' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @changes = @samanage.changes
      @users = @samanage.get_users[:data]
    end
      it 'get_changes: it returns API call of changes' do
        api_call = @samanage.get_changes
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it 'collect_changes: collects array of changes' do
        change_count = @samanage.get_changes[:total_count]
        @changes = @samanage.changes
        expect(@changes).to be_an(Array)
        expect(@changes.size).to eq(change_count)
      end
      it 'create_change(payload: json): creates a change' do
        users_email = @samanage.collect_users.sample['email']
        change_name = "Samanage Ruby change"
        json = {
          change: {
            requester: {email: users_email},
            name: change_name,
            priority: 'Low',
            description: "Description"
          }
        }
        change_create = @samanage.create_change(payload: json)

        expect(change_create[:data]['id']).to be_an(Integer)
        expect(change_create[:data]['name']).to eq(change_name)
        expect(change_create[:code]).to eq(200).or(201)
      end
      it 'create_change: fails if no name/title' do
        users_email = @users.sample['email']
        json = {
          :change => {
            :requester => {:email => users_email},
            :description => "Description"
          }
        }
        expect{@samanage.create_change(payload: json)}.to raise_error(Samanage::InvalidRequest)
      end
      it 'find_change: returns a change card by known id' do
        sample_id = @changes.sample['id']
        change = @samanage.find_change(id: sample_id)

        expect(change[:data]['id']).to eq(sample_id)  # id should match found change
        expect(change[:data]).to have_key('name')
        expect(change[:data]).to have_key('requester')
        expect(change[:data]).to have_key('id')
      end
      it 'find_change: returns more keys with layout=long' do
        sample_id = @changes.sample['id']
        layout_regular_change = @samanage.find_change(id: sample_id)
        layout_long_change = @samanage.find_change(id: sample_id, options: {layout: 'long'})

        expect(layout_long_change[:data]['id']).to eq(sample_id)  # id should match found change
        expect(layout_long_change[:data].keys.size).to be > (layout_regular_change.keys.size)
        expect(layout_long_change[:data].keys - layout_regular_change[:data].keys).to_not be([])
      end
      it 'find_change: returns nothing for an invalid id' do
        sample_id = (0..10).entries.sample
        expect{@samanage.find_change(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found change
      end
      it 'update_change: update_change by id' do
        sample_change = @changes.reject{|i| ['Closed','Resolved'].include? i['state']}.sample
        sample_id = sample_change['id']
        description = (0...500).map { ('a'..'z').to_a[rand(26)] }.join
        change_json = {
          :change => {
            :description => description
          }
        }
        change_update = @samanage.update_change(payload: change_json, id: sample_id)
        # expect(change_update[:data]['description']).to eq(description) # change bug #00044569
        expect(change_update[:code]).to eq(200).or(201)
      end
      it 'finds more data for option[:layout] = "long"' do
        full_layout_change_keys = @samanage.changes(options: {layout: 'long'}).first.keys
        basic_change_keys = @samanage.changes.sample.keys
        expect(basic_change_keys.size).to be < full_layout_change_keys.size
      end
      it 'deletes a valid change' do
        sample_change_id = @changes.sample['id']
        change_delete = @samanage.delete_change(id: sample_change_id)
        expect(change_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
