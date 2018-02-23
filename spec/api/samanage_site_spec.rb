require 'samanage'
describe Samanage::Api do
  context 'Site' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @sites = @samanage.sites
    end
    it 'get_users: it returns API call of users' do
      api_call = @samanage.get_sites
      expect(api_call).to be_a(Hash)
      expect(api_call[:total_count]).to be_an(Integer)
      expect(api_call).to have_key(:response)
      expect(api_call).to have_key(:code)
    end
    it 'collects all sites' do
      sites = @sites
      site_count = @samanage.get_sites[:total_count]
      expect(sites).to be_an(Array)
      expect(sites.size).to eq(site_count)
    end
    it 'creates a site' do
      site_name = "Site ##{(rand*10**4).ceil}"
      site_location = "Location #{(rand*10**4).ceil}"
      site_description = "Descrption #{(rand*10**4).ceil}"
      payload = {
        site: {
          name: site_name,
          location: site_location,
          description: site_description
        }
      }
      site_create = @samanage.create_site(payload: payload)

      expect(site_create[:data]['id']).to be_an(Integer)
      expect(site_create[:data]['name']).to eq(site_name)
      expect(site_create[:code]).to eq(201).or(200)
    end
    it 'deletes a valid site' do
      sample_site_id = @sites.sample['id']
      site_delete = @samanage.delete_site(id: sample_site_id)

      expect(site_delete[:code]).to eq(200).or(201)
    end
    it 'fails to delete invalid site' do 
      invalid_site_id = 0
      expect{@samanage.delete_site(id: invalid_site_id)}.to raise_error(Samanage::NotFound)
    end
  end
end