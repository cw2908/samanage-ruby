module Samanage
	class Api
		def get_hardwares(path: PATHS[:hardware], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		def collect_hardwares
			page = 1
			hardwares = Array.new
			total_pages = self.get_hardwares[:total_pages]
			# puts api_call
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "hardwares.json?page=#{page}")
				hardwares += api_call[:data]
				page += 1
			end
			hardwares
		end

		def create_hardware(payload: nil, options: {})
			api_call = self.execute(path: PATHS[:hardware], http_method: 'post', payload: payload)
			api_call
		end

		def find_hardware(id: nil)
			path = "hardwares/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

		def find_hardwares_by_serial(serial_number: nil)
			path = "hardwares.json?serial_number[]=#{serial_number}"
			api_call = self.execute(path: path)
			api_call
		end

		def check_hardware(options: {})
			url = Samanage::UrlBuilder.new(path: PATHS[:hardware], options: options).url
			puts "Url: #{url}"
			api_call = self.execute(path: url)
			api_call
		end


		def update_hardware(payload: nil, id: nil, options: {})
			path = "hardwares/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end