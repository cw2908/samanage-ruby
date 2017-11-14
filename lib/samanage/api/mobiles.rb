module Samanage
	class Api

		# Get mobile default path
		def get_mobiles(path: PATHS[:mobile], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		# Get all mobiles
		def collect_mobiles
			page = 1
			mobiles = Array.new
			total_pages = self.get_mobiles[:total_pages]
			puts api_call
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "mobiles.json?page=#{page}")
				mobiles += api_call[:data]
				page += 1
			end
			mobiles
		end

		# Create mobile given json payload
		def create_mobile(payload: nil, options: {})
			api_call = self.execute(path: PATHS[:mobile], http_method: 'post', payload: payload)
			api_call
		end

		# Find mobile given id
		def find_mobile(id: nil)
			path = "mobiles/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

		# Find mobile given a serial number
		def find_mobiles_by_serial(serial_number: nil)
			path = "mobiles.json?serial_number[]=#{serial_number}"
			api_call = self.execute(path: path)
			api_call
		end


		# Check for mobile using URL builder
		def check_mobile(options: {})
			url = Samanage::UrlBuilder.new(path: PATHS[:mobile], options: options).url
			puts "Url: #{url}"
			api_call = self.execute(path: url)
			api_call
		end

		# Update mobile given id
		def update_mobile(payload: nil, id: nil, options: {})
			path = "mobiles/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end