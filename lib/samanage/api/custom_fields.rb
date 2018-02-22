module Samanage
	class Api

		# Get custom fields default url
		def get_custom_fields(path: PATHS[:custom_fields], options:{})
			url = Samanage::UrlBuilder.new(path: path, options: options).url
			self.execute(path: url)
		end

		# Gets all custom fields
		def collect_custom_fields(options: {})
			custom_fields = Array.new
			total_pages = self.get_custom_fields[:total_pages] ||= 2
			1.upto(total_pages) do |page|
				puts "Collecting Custom Fields page: #{page}/#{total_pages}" if options[:verbose]
				self.execute(path: "custom_fields.json")[:data].each do |custom_field|
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
