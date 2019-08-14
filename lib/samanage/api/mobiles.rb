# frozen_string_literal: true

module Samanage
  class Api
    # Get mobile default path
    def get_mobiles(path: PATHS[:mobile], options: {})
      path = "mobiles.json?"
      self.execute(path: path, options: options)
    end

    # Get all mobiles
    def collect_mobiles(options: {})
      mobiles = Array.new
      total_pages = self.get_mobiles(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Mobiles page: #{page}/#{total_pages}" if options[:verbose]
        path = "mobiles.json?"
        self.execute(path: path, options: options)[:data].each do |mobile|
          if block_given?
            yield mobiles
          end
          mobiles << mobile
        end
      end
      mobiles
    end

    # Create mobile given json payload
    def create_mobile(payload: nil, options: {})
      self.execute(path: PATHS[:mobile], http_method: "post", payload: payload)
    end

    # Find mobile given id
    def find_mobile(id:, options: {})
      path = "mobiles/#{id}.json"
      self.execute(path: path)
    end

    # Check for mobile using URL builder
    def check_mobile(options: {})
      url = Samanage::UrlBuilder.new(path: PATHS[:mobile], options: options).url
      self.execute(path: url)
    end

    # Update mobile given id
    def update_mobile(payload:, id:, options: {})
      path = "mobiles/#{id}.json"
      self.execute(path: path, http_method: "put", payload: payload)
    end

    def delete_mobile(id:)
      self.execute(path: "mobiles/#{id}.json", http_method: "delete")
    end


    alias_method :mobiles, :collect_mobiles
  end
end
