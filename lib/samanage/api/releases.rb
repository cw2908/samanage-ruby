module Samanage
  class Api

    # Default get releases path
    def get_releases(path: PATHS[:release], options: {})
      
      path = 'releases.json?'
      self.execute(path: path, options: options)
    end

    # Returns all other assets
    def collect_releases(options: {})
      releases = Array.new
      total_pages = self.get_releases(options: options)[:total_pages]
      releases = []
      1.upto(total_pages) do |page|
        options[:page] = page
        
        puts "Collecting Other Assets page: #{page}/#{total_pages}" if options[:verbose]
        path = "releases.json?"
        self.execute(path: path, options: options)[:data].each do |release|
          if block_given?
            yield release
          end
          releases << release
        end
      end
      releases
    end


    # Create an release given json
    def create_release(payload: , options: {})
      self.execute(path: PATHS[:release], http_method: 'post', payload: payload)
    end


    # Find release by id
    def find_release(id: , options: {})
      path = "releases/#{id}.json"
      self.execute(path: path, options: {})
    end

     # Update release given json and id
    def update_release(payload: , id: , options: {})
      path = "releases/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_release(id: )
      self.execute(path: "releases/#{id}.json", http_method: 'delete')
    end


  alias_method :releases, :collect_releases
  end
end