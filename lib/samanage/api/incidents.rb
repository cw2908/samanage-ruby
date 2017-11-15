module Samanage
	class Api

		# Default get incident path
		def get_incidents(path: PATHS[:incident], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end


		# Returns all incidents
		def collect_incidents
			page = 1
			incidents = Array.new
			total_pages = self.get_incidents[:total_pages]
			while page <= total_pages
				incidents += self.execute(http_method: 'get', path: "incidents.json?page=#{page}")[:data]
				page += 1
			end
			incidents
		end


		# Create an incident given json
		def create_incident(payload: nil, options: {})
			self.execute(path: PATHS[:incident], http_method: 'post', payload: payload)
		end

		# Find incident by ID
		def find_incident(id: nil)
			path = "incidents/#{id}.json"
			self.execute(path: path)
		end

		# Update an incident given id and json
		def update_incident(payload: nil, id: nil, options: {})
			path = "incidents/#{id}.json"
			self.execute(path: path, http_method: 'put', payload: payload)
		end
	end
end