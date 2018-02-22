require 'samanage'
describe Samanage::Api do
  context 'category' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @categories = @samanage.collect_categories
    end
    it 'collects all categories' do
      expect(@categories).to be_an(Array)
    end

    it 'creates a category' do
      category_name = "category ##{(rand*10**4).ceil}"
      category_description = "Location #{(rand*10**4).ceil}"
      payload = {
        category: {
          name: category_name,
          description: category_description
        }
      }
      category_create = @samanage.create_category(payload: payload)

      expect(category_create[:data]['id']).to be_an(Integer)
      expect(category_create[:data]['name']).to eq(category_name)
      expect(category_create[:code]).to eq(200).or(201)
    end
  end
end
