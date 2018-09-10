module Samanage
  class Api
    # Get custom forms path
    def get_custom_forms(path: PATHS[:custom_forms], options: {})
      params = self.set_params(options: options)
      self.execute(path: path)
    end

    # Get all custom forms
    def collect_custom_forms(options: {})
      custom_forms = Array.new
      total_pages = self.get_custom_forms(options: options)[:total_pages]
      1.upto(total_pages) do |page|
        options[:page] = page
        params = self.set_params(options: options)
        puts "Collecting Custom Forms page: #{page}/#{total_pages}" if options[:verbose]
        path = "custom_forms.json?#{params}"
        self.execute(path: path)[:data].each do |custom_form|
          if block_given?
            yield custom_form
          end
          custom_forms << custom_form
        end
      end
      custom_forms
    end

    # Set forms by type and map fields
    def organize_forms
      custom_forms = self.collect_custom_forms
      custom_forms.map{|form| form.delete_if{|k, v| v.nil?}}
      custom_forms.map{|form| form['custom_form_fields'].map{|fields| fields.delete_if{|k, v| v == false}}}
      custom_forms.map{|form| form['custom_form_fields'].map{|fields| fields['custom_field'].delete_if{|k, v| !v}}}
      custom_forms.group_by{|k|
        k['module']}.each_pair{|forms_name, forms|
          forms.each{|form|
            form['custom_form_fields'].group_by{|f| f['name'] }
          }
        }
    end

    # Get form for a specific object type
    def form_for(object_type: nil)
      if self.custom_forms == nil
        self.custom_forms = self.organize_forms
      end
      self.custom_forms[object_type]
    end
  end
end