module Samanage
	class Api
		def get_other_assets(path: PATHS[:other_asset], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		def collect_other_assets
			page = 1
			other_assets = Array.new
			total_pages = self.get_other_assets[:total_pages]
			# puts api_call
			other_assets = []
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "other_assets.json?page=#{page}")
				other_assets << api_call[:data]
				page += 1
			end
			other_assets.uniq
		end

		def create_other_asset(payload: , options: {})
			api_call = self.execute(path: PATHS[:other_asset], http_method: 'post', payload: payload)
			api_call
		end

		def find_other_asset(id: )
			path = "other_assets/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

		def update_other_asset(payload:, id:, options: {})
			path = "other_assets/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end