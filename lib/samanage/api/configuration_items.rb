# frozen_string_literal: true

module Samanage
  class Api
    # Default get configuration_item path
    def get_configuration_items(path: PATHS[:configuration_item], options: {})
      path = "configuration_items.json?"
      self.execute(path: path, options: options)
    end


    # Returns all configuration_items.
    # Options:
    #   - audit_archives: true
    #   - layout: 'long'
    def collect_configuration_items(options: {})
      configuration_items = Array.new
      total_pages = self.get_configuration_items(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Configuration Items page: #{page}/#{total_pages}" if options[:verbose]
        path = "configuration_items.json?"
        request = self.execute(http_method: "get", path: path, options: options)
        request[:data].each do |configuration_item|
          if block_given?
            yield configuration_item
          end
          configuration_items << configuration_item
        end
      end
      configuration_items
    end


    # Create an configuration_item given json
    def create_configuration_item(payload: nil, options: {})
      self.execute(path: PATHS[:configuration_item], http_method: "post", payload: payload)
    end

    # Find configuration_item by ID
    def find_configuration_item(id:, options: {})
      path = "configuration_items/#{id}.json"
      if options[:layout] == "long"
        path += "?layout=long"
      end
      self.execute(path: path)
    end

    # Update an configuration_item given id and json
    def update_configuration_item(payload:, id:, options: {})
      path = "configuration_items/#{id}.json"
      self.execute(path: path, http_method: "put", payload: payload)
    end

    def delete_configuration_item(id:)
      self.execute(path: "configuration_items/#{id}.json", http_method: "delete")
    end


    alias_method :configuration_items, :collect_configuration_items
  end
end
