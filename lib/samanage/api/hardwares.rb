module Samanage
	class Api

		# Get hardware default path
		def get_hardwares(path: PATHS[:hardware], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		# Get all hardwares
		def collect_hardwares(options: {})
			hardwares = Array.new
			total_pages = self.get_hardwares[:total_pages]
			1.upto(total_pages) do |page|
				puts "Collecting Hardwares page: #{page}/#{total_pages}" if options[:verbose]
				self.execute(http_method: 'get', path: "hardwares.json?page=#{page}")[:data].each do |hardware|
					if block_given?
						yield hardware
					end
					hardwares << hardware
				end
			end
			hardwares
		end

		# Create hardware given json payload
		def create_hardware(payload: , options: {})
			self.execute(path: PATHS[:hardware], http_method: 'post', payload: payload)
		end

		# Find hardware given id
		def find_hardware(id: )
			path = "hardwares/#{id}.json"
			self.execute(path: path)
		end

		# Find hardware given a serial number
		def find_hardwares_by_serial(serial_number: )
			path = "hardwares.json?serial_number[]=#{serial_number}"
			self.execute(path: path)
		end


		# Check for hardware using URL builder
		def check_hardware(options: {})
			url = Samanage::UrlBuilder.new(path: PATHS[:hardware], options: options).url
			self.execute(path: url)
		end

		# Update hardware given id
		def update_hardware(payload: , id: , options: {})
			path = "hardwares/#{id}.json"
			self.execute(path: path, http_method: 'put', payload: payload)
		end

		def delete_hardware(id: )
			self.execute(path: "hardwares/#{id}.json", http_method: 'delete')
		end

	alias_method :hardwares, :collect_hardwares
	end
end