module Samanage
	class Api
		PATHS = {
			hardware: 'hardwares.json',
			user: 'users.json',
			incident: 'incidents.json',
			other_asset: 'other_assets.json',
			custom_fields: 'custom_fields.json',
			custom_forms: 'custom_forms.json',
		}
		attr_accessor :datacenter, :content_type, :base_url, :token, :custom_forms
		def initialize(token: '', dacenter: '', development_mode: false)
			self.token = token
			self.datacenter = nil || datacenter
			self.base_url = "https://api#{datacenter}.samanage.com/"
			# self.content_type = content_type || 'json'
			self.content_type = 'json'
			self.authorize
			if development_mode
				self.custom_forms = self.organize_forms
			end
		end

		def authorize
			self.execute(path: 'api.json')
			rescue OpenSSL::SSL::SSLError => e
				puts "Raised: #{e} #{e.class}"
				puts 'Disabling Local SSL Verification'
				self.execute(path: 'api.json', ssl_fix: true)
		end

		# Defaults to GET
		def execute(http_method: 'get', path: nil, payload: nil, verbose: nil, ssl_fix: false)
			unless verbose.nil?
				verbose = '?layout=long'
			end

			api_call = HTTP.headers(
				'Accept' => "application/vnd.samanage.v2.0+#{self.content_type}#{verbose}",
				'Content-type'  => "application/#{self.content_type}",
				'X-Samanage-Authorization' => 'Bearer ' + self.token
			)
			ctx = OpenSSL::SSL::SSLContext.new
			if ssl_fix
				ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			api_call = api_call.public_send(http_method.to_sym, self.base_url + Addressable::URI.encode_component(path, Addressable::URI::CharacterClasses::QUERY).gsub('+',"%2B"), :body => payload, ssl_context: ctx)
			response = Hash.new
			response[:code] = api_call.code.to_i
			response[:json] = api_call.body
			response[:response] = api_call
			response[:headers] = api_call.headers
			response[:total_pages] = api_call.headers['X-Total-Pages'].to_i
			response[:total_pages] = 1 if response[:total_pages] == 0
			response[:total_count] = api_call.headers['X-Total-Count'].to_i

			# puts "Body Class: #{api_call.body.class}"
			# puts "#{api_call.body}"
			# Raise error if not Authentication or 200,201  == Success,Okay
			# Error cases
			case response[:code]
			when 200..201
				response[:data] = JSON.parse(api_call.body)
				response
			when 401
				response[:data] = api_call.body
				error = response[:response]
				raise Samanage::AuthorizationError.new(error: error,response: response)
			when 404
				response[:data] = api_call.body
				error = response[:response]
				raise Samanage::NotFound.new(error: error, response: response)
			when 422
				response[:data] = api_call.body
				error = response[:response]
				raise Samanage::InvalidRequest.new(error: error, response: response)
			else
				response[:data] = api_call.body
				error = response[:response]
				raise Samanage::InvalidRequest.new(error: error, response: response)
			end
		# Always return response hash
		response
		end
	end
end
