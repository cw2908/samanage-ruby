module Samanage
	class Api

		# Default get incident path
		def get_incidents(path: PATHS[:incident], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end


		# Returns all incidents
		def collect_incidents
			page = 1
			incidents = Array.new
			total_pages = self.get_incidents[:total_pages]
			# puts api_call
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "incidents.json?page=#{page}")
				incidents += api_call[:data]
				page += 1
			end
			incidents
		end


		# Create an incident given json
		def create_incident(payload: nil, options: {})
			api_call = self.execute(path: PATHS[:incident], http_method: 'post', payload: payload)
			api_call
		end

		# Find incident by ID
		def find_incident(id: nil)
			path = "incidents/#{id}.json"
			api_call = self.execute(path: path)
			api_call
		end

		# Update an incident given id and json
		def update_incident(payload: nil, id: nil, options: {})
			path = "incidents/#{id}.json"
			api_call = self.execute(path: path, http_method: 'put', payload: payload)
			api_call
		end
	end
end