module Samanage
	class Api

		# Default get incident path
		def get_incidents(path: PATHS[:incident], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end


		# Returns all incidents. 
		# Options: 
		#   - audit_archives: true
		#   - layout: 'long'
		def collect_incidents(options: {})
			incidents = Array.new
			total_pages = self.get_incidents[:total_pages]
			puts "Pulling Incidents with Audit Archives (this may take a while)" if options[:audit_archives] && options[:verbose]
			1.upto(total_pages) do |page|
				puts "Collecting Incidents page: #{page}/#{total_pages}" if options[:verbose]
				if options[:audit_archives]
					archives = 'layout=long&audit_archive=true'
					paginated_incidents = self.execute(path: "incidents.json?page=#{page}")[:data]
					paginated_incidents.map do |incident|
						archive_path = "incidents/#{incident['id']}.json?#{archives}"
						incidents << self.execute(path: archive_path)[:data]
					end
				else
					layout = options[:layout] == 'long' ? '&layout=long' : nil
					incidents += self.execute(http_method: 'get', path: "incidents.json?page=#{page}#{layout}")[:data]
				end
			end
			incidents
		end


		# Create an incident given json
		def create_incident(payload: nil, options: {})
			self.execute(path: PATHS[:incident], http_method: 'post', payload: payload)
		end

		# Find incident by ID
		def find_incident(id: , options: {})
			path = "incidents/#{id}.json"
			if options[:layout] == 'long'
				path += '?layout=long'
			end
			self.execute(path: path)
		end

		# Update an incident given id and json
		def update_incident(payload: , id: , options: {})
			path = "incidents/#{id}.json"
			self.execute(path: path, http_method: 'put', payload: payload)
		end

		def delete_incident(id: )
      self.execute(path: "incidents/#{id}.json", http_method: 'delete')
    end


	alias_method :incidents, :collect_incidents
	end
end