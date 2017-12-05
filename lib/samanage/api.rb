module Samanage
	class Api
		include HTTParty
		ssl_ca_file "#{File.expand_path('..')}/data/cacert.pem"


		PATHS = {
			hardware: 'hardwares.json',
			user: 'users.json',
			incident: 'incidents.json',
			other_asset: 'other_assets.json',
			mobile: 'mobiles.json',
			custom_fields: 'custom_fields.json',
			custom_forms: 'custom_forms.json',
		}
		attr_accessor :datacenter, :content_type, :base_url, :token, :custom_forms, :authorized, :admins

		# Development mode forzes authorization & prepopulates custom forms/fields and admins
		# datacenter should equal 'eu' or blank
		def initialize(token: nil, datacenter: nil, development_mode: false)
			self.token = token if token
			if !datacenter.nil? && datacenter.to_s.downcase != 'eu'
				self.datacenter = nil
			end
			self.base_url =  "https://api#{self.datacenter}.samanage.com/"
			self.datacenter = datacenter if datacenter
			self.content_type = 'json'
			self.admins = []
			if development_mode
				if self.authorized? != true
					self.authorize
				end
				self.custom_forms = self.organize_forms
				self.admins = self.list_admins
			end
		end

		def authorized?
			self.authorized
		end

		# Check token against api.json
		def authorize
			self.execute(path: 'api.json')
			rescue OpenSSL::SSL::SSLError => e
				puts "Raised: #{e} #{e.class}"
				puts 'Disabling Local SSL Verification'
				self.execute(path: 'api.json', ssl_fix: true)
			self.authorized = true
		end

		# Calling execute without a method defaults to GET
		def execute(http_method: 'get', path: nil, payload: nil, verbose: nil, ssl_fix: false)
			if payload.class == String
				begin
				payload = JSON.parse(payload)
				rescue => e
					puts "Invalid JSON: #{payload.inspect}"
					raise Samanage::Error(error: e, response: nil)
				end
			end
			token = token ||= self.token
			unless verbose.nil?
				verbose = '?layout=long'
			end

			headers = {
				'Accept' => "application/vnd.samanage.v2.0+#{self.content_type}#{verbose}",
				'Content-type'  => "application/#{self.content_type}",
				'X-Samanage-Authorization' => 'Bearer ' + self.token
			}
			full_path = self.base_url + path
			case http_method.to_s.downcase
			when 'get'
				api_call = HTTParty.get(full_path, headers: headers)
			when 'post'
				api_call = HTTParty.post(full_path, query: payload, headers: headers)
			when 'put'
				api_call = HTTParty.put(full_path, query: payload, headers: headers)
			end

			response = Hash.new
			response[:code] = api_call.code.to_i
			response[:json] = api_call.body
			response[:response] = api_call
			response[:headers] = api_call.headers
			response[:total_pages] = api_call.headers['X-Total-Pages'].to_i
			response[:total_pages] = 1 if response[:total_pages] == 0
			response[:total_count] = api_call.headers['X-Total-Count'].to_i

			# Error cases
			case response[:code]
			when 200..201
				response[:data] = JSON.parse(api_call.body)
				response
			when 401
				response[:data] = api_call.body
				error = response[:response]
				self.authorized = false
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
			rescue Errno::ECONNREFUSED => e
				error = e
				response = e.class
				raise Samanage::InvalidRequest.new(error: error, response: response)
		end


		# Return all admins in the account
		def list_admins
			admin_role_id = self.execute(path: 'roles.json')[:data].select{|role| role['name'] == 'Administrator'}.first['id']
			self.admins.push(
				self.execute(path: "users.json?role=#{admin_role_id}")[:data].map{|u| u['email']}
			).flatten
		end
	end
end
