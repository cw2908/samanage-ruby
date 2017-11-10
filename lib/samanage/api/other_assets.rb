module Samanage
	class Api

		# Default get other_assets path
		def get_other_assets(path: PATHS[:other_asset], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		# Returns all other assets
		def collect_other_assets
			page = 1
			other_assets = Array.new
			total_pages = self.get_other_assets[:total_pages]
			# puts api_call
			other_assets = []
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "other_assets.json?page=#{page}")
				other_assets += api_call[:data]
				page += 1
			end
			other_assets.uniq
		end


		# Create an other_asset given json
		def create_other_asset(payload: nil, options: {})
			api_call = self.execute(path: PATHS[:other_asset], http_method: 'post', payload: payload)
			api_call
		end


		# Find other_asset by id
		def find_other_asset(id: nil)
			path = "other_assets/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

 		# Update other_asset given json and id
		def update_other_asset(payload: nil, id: nil, options: {})
			path = "other_assets/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end