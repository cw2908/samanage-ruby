module Samanage
  class Api
    
    # Default get incident path
    def get_incidents(path: PATHS[:incident], options: {})
      
      path = 'incidents.json?'
      self.execute(path: path,options: options)
    end


    # Returns all incidents. 
    # Options: 
    #   - audit_archives: true
    #   - layout: 'long'
    def collect_incidents(options: {})
      incidents = Array.new
      total_pages = self.get_incidents(options: options.except(:audit_archives,:audit_archive,:layout))[:total_pages]
      puts "Pulling Incidents with Audit Archives (this may take a while)" if options[:audit_archives] && options[:verbose]
      1.upto(total_pages) do |page|
        puts "Collecting Incidents page: #{page}/#{total_pages}" if options[:verbose]
        if options[:audit_archives]
          options[:page] = page
          params = URI.encode_www_form(options.except(:audit_archives,:audit_archive,:layout)) # layout not needed as audit only on individual record
          paginated_path = "incidents.json?"
          paginated_incidents = self.execute(path: paginated_path, options: options)[:data]
          paginated_incidents.map do |incident|
            params = self.set_params(options: options.except(:audit_archives,:audit_archive,:layout))
            archive_uri = "incidents/#{incident['id']}.json?layout=long&audit_archive=true"
            incident_with_archive = self.execute(path: archive_uri)[:data]
            if block_given?
              yield incident_with_archive
            end
            incidents.push(incident_with_archive)
          end
        else
          options[:page] = page
          
          path = "incidents.json?"
          self.execute(path: path, options: options)[:data].each do |incident|
            if block_given?
              yield incident
            end
            incidents.push(incident)
          end
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

      
      path = "incidents/#{id}.json?"
      self.execute(path: path, options: options)
    end

    # Update an incident given id and json
    def update_incident(payload: , id: , options: {})
      
      path = "incidents/#{id}.json?"
      self.execute(path: path, http_method: 'put', payload: payload, options: options)
    end

    def delete_incident(id: )
      self.execute(path: "incidents/#{id}.json", http_method: 'delete')
    end


  alias_method :incidents, :collect_incidents
  end
end
