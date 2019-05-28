module Samanage
  class Api
    def get_vendors(path: PATHS[:vendor], options: {})
      
      path = 'vendors.json?'
      self.execute(path: path, options: options)
    end

    def collect_vendors(options: {})
      vendors = Array.new
      total_pages = self.get_vendors(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        
        puts "Collecting Vendors page: #{page}/#{total_pages}" if options[:verbose]
        path = "vendors.json?"
        self.execute(http_method: 'get', path: path, options: options)[:data].each do |vendor|
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