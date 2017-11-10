module Samanage
	class Api

		# Get custom fields default url
		def get_custom_fields(path: PATHS[:custom_fields], options:{})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		# Gets all custom fields
		def collect_custom_fields
			page = 1
			custom_fields = Array.new
			total_pages = self.get_custom_fields[:total_pages] ||= 2
			while page <= total_pages
				api_call = self.execute(path: "custom_fields.json")
				custom_fields += api_call[:data]
				page += 1
			end
			custom_fields
		end
	end
end
