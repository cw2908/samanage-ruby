module Samanage
  class Api
    def get_vendors(path: PATHS[:vendor], options: {})
      params = self.set_params(options: options)
      path = 'vendors.json?' + params
      self.execute(path: path)
    end

    def collect_vendors(options: {})
      vendors = Array.new
      total_pages = self.get_vendors(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting vendors page: #{page}/#{total_pages}" if options[:verbose]
        path = "vendors.json?" + params
        self.execute(http_method: 'get', path: path)[:data].each do |vendor|
          if block_given?
            yield vendor
          end
          vendors << vendor
        end
      end
      vendors
    end

    def create_vendor(payload: , options: {})
      self.execute(path: PATHS[:vendor], http_method: 'post', payload: payload)
    end
    
    def update_vendor(id: ,payload: , options: {})
      self.execute(path: "vendors/#{id}.json", http_method: 'put', payload: payload)
    end

    def delete_vendor(id: )
      self.execute(path: "vendors/#{id}.json", http_method: 'delete')
    end

  alias_method :vendors, :collect_vendors
  end
end