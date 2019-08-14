# frozen_string_literal: true

module Samanage
  class Api
    def get_sites(path: PATHS[:site], options: {})
      path = "sites.json?"
      self.execute(path: path, options: options)
    end

    def collect_sites(options: {})
      sites = Array.new
      total_pages = self.get_sites(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Sites page: #{page}/#{total_pages}" if options[:verbose]
        path = "sites.json?"
        self.execute(path: path, options: options)[:data].each do |site|
          if block_given?
            yield site
          end
          sites << site
        end
      end
      sites
    end

    def create_site(payload:, options: {})
      self.execute(path: PATHS[:site], http_method: "post", payload: payload)
    end

    def delete_site(id:)
      self.execute(path: "sites/#{id}.json", http_method: "delete")
    end

    alias_method :sites, :collect_sites
  end
end
