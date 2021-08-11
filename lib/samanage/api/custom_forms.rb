# frozen_string_literal: true
module Samanage
  class Api
    # Get custom forms path
    def get_custom_forms(path: PATHS[:custom_forms], options: {})
      self.execute(path: path)
    end

    # Get all custom forms
    def collect_custom_forms(options: {})
      custom_forms = Array.new
      total_pages = self.get_custom_forms(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page

        puts "Collecting Custom Forms page: #{page}/#{total_pages}" if options[:verbose]
        path = "custom_forms.json?"
        self.execute(path: path, options: options)[:data].each do |custom_form|
          if block_given?
            yield custom_form
          end
          custom_forms << custom_form
        end
      end
      custom_forms
    end

    # Get form for a specific object type
    def form_for(form_name: nil)
      cf = self.collect_custom_forms
                .to_a.find { |form| form["name"].match?(/#{form_name}/i)}
    end
  end
end