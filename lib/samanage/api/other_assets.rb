module Samanage
  class Api

    # Default get other_assets path
    def get_other_assets(path: PATHS[:other_asset], options: {})
      params = self.set_params(options: options)
      path = 'other_assets.json' + params
      self.execute(path: path)
    end

    # Returns all other assets
    def collect_other_assets(options: {})
      other_assets = Array.new
      total_pages = self.get_other_assets(options: options)[:total_pages]
      other_assets = []
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting Other Assets page: #{page}/#{total_pages}" if options[:verbose]
        self.execute(http_method: 'get', path: "other_assets.json?page=#{page}")[:data].each do |other_asset|
          if block_given?
            yield other_asset
          end
          other_assets << other_asset
        end
      end
      other_assets
    end


    # Create an other_asset given json
    def create_other_asset(payload: , options: {})
      self.execute(path: PATHS[:other_asset], http_method: 'post', payload: payload)
    end


    # Find other_asset by id
    def find_other_asset(id: )
      path = "other_assets/#{id}.json"
      self.execute(path: path)
    end

     # Update other_asset given json and id
    def update_other_asset(payload: , id: , options: {})
      path = "other_assets/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_other_asset(id: )
      self.execute(path: "other_assets/#{id}.json", http_method: 'delete')
    end


  alias_method :other_assets, :collect_other_assets
  end
end