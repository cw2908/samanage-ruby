require 'samanage'
require 'faker'
describe Samanage::Api do
  context 'vendor' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @vendors = @samanage.vendors
    end
    it 'get_users: it returns API call of users' do
      api_call = @samanage.get_vendors
      expect(api_call).to be_a(Hash)
      expect(api_call[:total_count]).to be_an(Integer)
      expect(api_call).to have_key(:response)
      expect(api_call).to have_key(:code)
    end
    it 'collects all vendors' do
      vendors = @vendors
      vendor_count = @samanage.get_vendors[:total_count]
      expect(vendors).to be_an(Array)
      expect(vendors.size).to eq(vendor_count)
    end
    it 'creates a vendor' do
      vendor_name = Faker::Music.album
      payload = {
        vendor: {
          name: vendor_name,
          vendor_type: {name: 'SaaS Vendor'}
        }
      }
      vendor_create = @samanage.create_vendor(payload: payload)

      expect(vendor_create[:data]['id']).to be_an(Integer)
      expect(vendor_create[:data]['name']).to eq(vendor_name)
      expect(vendor_create[:code]).to eq(200)
    end
    it 'updates a valid vendor' do
      sample_vendor_id = @vendors.sample['id']
      new_name = Faker::Movie.quote
      payload = {vendor: {name: new_name}}
      vendor_update = @samanage.update_vendor(id: sample_vendor_id, payload: payload)
      
      expect(new_name).to eq(vendor_update.dig(:data,'name'))
      expect(vendor_update[:code]).to eq(200)
    end
  end
end