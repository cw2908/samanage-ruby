module Samanage
  class Api

    # Get contract default path
    def get_contracts(path: PATHS[:contract], options: {})
      
      path = 'contracts.json?'
      self.execute(path: path, options: options)
    end

    # Get all contracts
    def collect_contracts(options: {})
      contracts = Array.new
      total_pages = self.get_contracts(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        
        puts "Collecting contracts page: #{page}/#{total_pages}" if options[:verbose]
        path = "contracts.json?"
        self.execute(path: path, options: options)[:data].each do |contract|
          if block_given?
            yield contract
          end
          contracts << contract
        end
      end
      contracts
    end

    # Create contract given json payload
    def create_contract(payload: , options: {})
      self.execute(path: PATHS[:contract], http_method: 'post', payload: payload)
    end

    # Find contract given id
    def find_contract(id: , options: {})
      path = "contracts/#{id}.json"
      self.execute(path: path, options: {})
    end
    
    # Check for contract using URL builder
    def check_contract(options: {})
      url = Samanage::UrlBuilder.new(path: PATHS[:contract], options: options).url
      self.execute(path: url)
    end

    # Update contract given id
    def update_contract(payload: , id: , options: {})
      path = "contracts/#{id}.json"
      self.execute(path: path, http_method: 'put', payload: payload)
    end

    def add_item_to_contract(id: , payload: )
      path = "contracts/#{id}/items.json"
      self.execute(path: path, http_method: 'post', payload: payload)
    end
    
    def delete_contract(id: )
      self.execute(path: "contracts/#{id}.json", http_method: 'delete')
    end



  alias_method :contracts, :collect_contracts
  end
end