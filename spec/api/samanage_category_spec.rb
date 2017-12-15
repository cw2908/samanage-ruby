require 'samanage'
describe Samanage::Api do
	context 'category' do
		before(:each) do
			TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
			@controller = Samanage::Api.new(token: TOKEN)
		end
		it 'collects all categories' do
			categories = @controller.categories
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
		it 'sorts subcategories properly' do
			unstacked_categories = @controller.categories
			stacked_categories = @controller.categories(stack_subcategories: true)
			3.times do |n|
				sample_category_id = categories.reject!{|c| c['parent_id']}.sample['id']
				sample_subcategories = categories.select!{|c| c['parent_id'] == sample_category_id}
				sample_stacked_categories = stacked_categories.select{|c| c['id'] == sample_category_id }

				expect(sample_subcategories.size).to eq(sample_stacked_categories.size)
			end
		end
	end
end