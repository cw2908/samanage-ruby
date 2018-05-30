module Samanage
  class Api

    # Default get change path
    def get_changes(path: PATHS[:change], options: {})
      url = Samanage::UrlBuilder.new(path: path, options: options).url
      self.execute(path: url)
    end


    # Returns all changes. 
    # Options: 
    #   - audit_archives: true
    #   - layout: 'long'
    def collect_changes(options: {})
      changes = Array.new
      total_pages = self.get_changes[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting changes page: #{page}/#{total_pages}" if options[:verbose]
        path = "changes.json?" + params
        self.execute(http_method: 'get', path: path)[:data].each do |change|
          if block_given?
            yield change
          end
          changes << change
        end
      end
      changes
    end


    # Create an change given json
    def create_change(payload: nil, options: {})
      self.execute(path: PATHS[:change], http_method: 'post', payload: payload)
    end

    # Find change by ID
    def find_change(id: , options: {})
      path = "changes/#{id}.json"
      if options[:layout] == 'long'
        path += '?layout=long'
      end
      self.execute(path: path)
    end

    # Update an change given id and json
    def update_change(payload: , id: , options: {})
      path = "changes/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_change(id: )
      self.execute(path: "changes/#{id}.json", http_method: 'delete')
    end


  alias_method :changes, :collect_changes
  end
end