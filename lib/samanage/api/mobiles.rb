module Samanage
	class Api

		# Get mobile default path
		def get_mobiles(path: PATHS[:mobile], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		# Get all mobiles
		def collect_mobiles
			page = 1
			mobiles = Array.new
			total_pages = self.get_mobiles[:total_pages]
			while page <= total_pages
				mobiles += self.execute(http_method: 'get', path: "mobiles.json?page=#{page}")[:data]
				page += 1
			end
			mobiles
		end

		# Create mobile given json payload
		def create_mobile(payload: nil, options: {})
			self.execute(path: PATHS[:mobile], http_method: 'post', payload: payload)
		end

		# Find mobile given id
		def find_mobile(id: nil)
			path = "mobiles/#{id}.json"
			self.execute(path: path)
		end
		
		# Check for mobile using URL builder
		def check_mobile(options: {})
			url = Samanage::UrlBuilder.new(path: PATHS[:mobile], options: options).url
			self.execute(path: url)
		end

		# Update mobile given id
		def update_mobile(payload: nil, id: nil, options: {})
			path = "mobiles/#{id}.json"
			self.execute(path: path, http_method: 'put', payload: payload)
		end


	alias_method :mobiles, :collect_mobiles
	end
end