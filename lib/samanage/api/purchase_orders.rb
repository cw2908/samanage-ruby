module Samanage
  class Api

    # Default get purchase_order path
    def get_purchase_orders(path: PATHS[:purchase_order], options: {})
      
      path = 'purchase_orders.json?'
      self.execute(path: path, options: options)
    end


    # Returns all purchase_orders. 
    # Options: 
    #   - audit_archives: true
    #   - layout: 'long'
    def collect_purchase_orders(options: {})
      purchase_orders = Array.new
      total_pages = self.get_purchase_orders(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        
        puts "Collecting Purchase Orders page: #{page}/#{total_pages}" if options[:verbose]
        path = "purchase_orders.json?"
        request = self.execute(http_method: 'get', path: path, options: options)
        request[:data].each do |purchase_order|
          if block_given?
            yield purchase_order
          end
          purchase_orders << purchase_order
        end
      end
      purchase_orders
    end


    # Create an purchase_order given json
    def create_purchase_order(payload: nil, options: {})
      self.execute(path: PATHS[:purchase_order], http_method: 'post', payload: payload)
    end

    # Find purchase_order by ID
    def find_purchase_order(id: , options: {})
      path = "purchase_orders/#{id}.json"
      if options[:layout] == 'long'
        path += '?layout=long'
      end
      self.execute(path: path)
    end

    # Update an purchase_order given id and json
    def update_purchase_order(payload: , id: , options: {})
      path = "purchase_orders/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def delete_purchase_order(id: )
      self.execute(path: "purchase_orders/#{id}.json", http_method: 'delete')
    end

  alias_method :purchase_orders, :collect_purchase_orders
  end
end