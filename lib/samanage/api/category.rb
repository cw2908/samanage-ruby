module Samanage
	class Api
		def get_categories(path: PATHS[:category], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end


		# Samanage categories are not paginated
		# - to break into subcategories, add
		def collect_categories
			categories = Array.new
			categories += self.execute(http_method: 'get', path: "categories.json")[:data]
		end

		def create_category(payload: nil, options: {})
			self.execute(path: PATHS[:category], http_method: 'post', payload: payload)
		end

		# def find_category(name: )
		# 	self.categories
		# end

	alias_method :categories, :collect_categories
	end
end