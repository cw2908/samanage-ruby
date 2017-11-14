module Samanage
	class Api

		# Get custom fields default url
		def get_custom_fields(path: PATHS[:custom_fields], options:{})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		# Gets all custom fields
		def collect_custom_fields
			page = 1
			custom_fields = Array.new
			total_pages = self.get_custom_fields[:total_pages] ||= 2
			while page <= total_pages
				custom_fields += self.execute(path: "custom_fields.json")[:data]
				page += 1
			end
			custom_fields
		end
	end
end
