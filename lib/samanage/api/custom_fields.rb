# frozen_string_literal: true

module Samanage
  class Api
    # Get custom fields default url
    def get_custom_fields(path: PATHS[:custom_fields], options: {})
      path = "custom_fields.json?"
      self.execute(path: path, options: options)
    end

    # Gets all custom fields
    def collect_custom_fields(options: {})
      custom_fields = Array.new
      total_pages = self.get_custom_fields(options: options)[:total_pages] ||= 2
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Custom Fields page: #{page}/#{total_pages}" if options[:verbose]
        path = "custom_fields.json?"
        self.execute(path: path, options: options)[:data].each do |custom_field|
          if block_given?
            yield custom_field
          end
          custom_fields << custom_field
        end
      end
      custom_fields
    end


    alias_method :custom_fields, :collect_custom_fields
  end
end
