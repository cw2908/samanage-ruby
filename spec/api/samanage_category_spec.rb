require 'samanage'
describe Samanage::Api do
	context 'category' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
		it 'collects all categories' do
			puts "Category methods: #{@controller.methods}"
			categories = @controller.collect_categories
			category_count = categories[:total_count]
			expect(categories).to be_an(Array)
		end
		it 'creates a category' do
			category_name = "category ##{(rand*10**4).ceil}"
			category_location = "Location #{(rand*10**4).ceil}"
			category_description = "Location #{(rand*10**4).ceil}"
			payload = {
				category: {
					name: category_name,
					description: category_description
				}
			}
			category_create = @controller.create_category(payload: payload)

			expect(category_create[:data]['id']).to be_an(Integer)
			expect(category_create[:data]['name']).to eq(category_name)
			expect(category_create[:code]).to eq(201).or(200)
		end
	end
end