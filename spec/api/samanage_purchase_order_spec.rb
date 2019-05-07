require 'samanage'
require 'faker'
describe Samanage::Api do
  context 'purchase_orders' do
    describe 'API Functions' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @purchase_orders = @samanage.purchase_orders
      @users = @samanage.get_users[:data]
      @vendors = @samanage.get_vendors[:data]
    end
      it 'get_purchase_orders: it returns API call of purchase_orders' do
        api_call = @samanage.get_purchase_orders
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it 'collect_purchase_orders: collects array of purchase_orders' do
        purchase_order_count = @samanage.get_purchase_orders[:total_count]
        @purchase_orders = @samanage.purchase_orders
        expect(@purchase_orders).to be_an(Array)
        expect(@purchase_orders.size).to eq(purchase_order_count)
      end
      it 'create_purchase_order(payload: json): creates a purchase_order' do
        users_email = @users.find{|u| u['role']['name']=='Administrator'}.to_h['email']
        purchase_order_name = Faker::Book.title
        json = {
          purchase_order: {
            buyer: {email: users_email},
            name: purchase_order_name,
            vendor: {name: @vendors.sample['name']}
          }
        }
        purchase_order_create = @samanage.create_purchase_order(payload: json)
        expect(purchase_order_create[:data]['id']).to be_an(Integer)
        expect(purchase_order_create[:data]['name']).to eq(purchase_order_name)
        expect(purchase_order_create[:code]).to eq(200).or(201)
      end
      it 'create_purchase_order: fails if no vendor' do
        users_email = @users.sample['email']
        json = {
          :purchase_order => {
            :buyer => {:email => users_email},
            :description => "Description"
          }
        }
        expect{@samanage.create_purchase_order(payload: json)}.to raise_error(Samanage::InvalidRequest)
      end
      it 'find_purchase_order: returns a purchase_order card by known id' do
        sample_id = @purchase_orders.sample['id']
        purchase_order = @samanage.find_purchase_order(id: sample_id)
        expect(purchase_order[:data]['id']).to eq(sample_id)  # id should match found purchase_order
        expect(purchase_order[:data]).to have_key('name')
        expect(purchase_order[:data]).to have_key('id')
      end

      it 'find_purchase_order: returns nothing for an invalid id' do
        sample_id = (0..10).entries.sample
        expect{@samanage.find_purchase_order(id: sample_id)}.to raise_error(Samanage::NotFound)  # id should match found purchase_order
      end
      it 'update_purchase_order: update_purchase_order by id' do
        sample_purchase_order = @purchase_orders.reject{|i| ['Closed','Resolved'].include? i['state']}.sample
        sample_id = sample_purchase_order['id']
        description = (0...500).map { ('a'..'z').to_a[rand(26)] }.join
        purchase_order_json = {
          :purchase_order => {
            :description => description
          }
        }
        purchase_order_update = @samanage.update_purchase_order(payload: purchase_order_json, id: sample_id)
        # expect(purchase_order_update[:data]['description']).to eq(description) # purchase_order bug #00044569
        expect(purchase_order_update[:code]).to eq(200).or(201)
      end
      it 'deletes a valid purchase_order' do
        sample_purchase_order_id = @purchase_orders.sample['id']
        purchase_order_delete = @samanage.delete_purchase_order(id: sample_purchase_order_id)
        expect(purchase_order_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
