module Samanage
	class Api
		def get_custom_forms(path: PATHS[:custom_forms], options: {})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			api_call = self.execute(path: url)
			api_call
		end

		def collect_custom_forms
			page = 1
			custom_forms = Array.new
			total_pages = self.get_custom_forms[:total_pages]
			# puts api_call
			while page <= total_pages
				api_call = self.execute(http_method: 'get', path: "custom_forms.json?page=#{page}")
				custom_forms += api_call[:data]
				page += 1
			end
			custom_forms
		end

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
		def form_for(object_type: )
			if self.custom_forms == nil
				self.custom_forms = self.organize_forms
			end
			self.custom_forms[object_type]
		end
	end
end