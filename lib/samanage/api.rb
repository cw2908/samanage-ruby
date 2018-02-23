require 'open-uri'
module Samanage
  class Api
    include HTTMultiParty
    MAX_RETRIES = 3
    PATHS = {
      category: 'categories.json',
      contract: 'contracts.json',
      change: 'changes.json',
      custom_fields: 'custom_fields.json',
      custom_forms: 'custom_forms.json',
      department: 'departments.json',
      group: 'groups.json',
      hardware: 'hardwares.json',
      incident: 'incidents.json',
      mobile: 'mobiles.json',
      other_asset: 'other_assets.json',
      site: 'sites.json',
      user: 'users.json',
    }
    attr_accessor :datacenter, :content_type, :base_url, :token, :custom_forms, :authorized, :admins, :max_retries

    # Development mode forces authorization & pre-populates admins and custom forms / fields
    # datacenter should equal 'eu' or blank
    def initialize(token: , datacenter: nil, development_mode: false, max_retries: MAX_RETRIES)
      self.token = token
      if !datacenter.nil? && datacenter.to_s.downcase != 'eu'
        datacenter = nil
      end
      self.datacenter ||= datacenter.to_s.downcase
      self.base_url =  "https://api#{self.datacenter.to_s.downcase}.samanage.com/"
      self.content_type = 'json'
      self.admins = []
      self.max_retries = max_retries
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
      self.authorized = true
    end

    # Calling execute without a method defaults to GET
    def execute(http_method: 'get', path: nil, payload: nil, verbose: nil, headers: {})
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

      headers = headers.merge({
        'Accept' => "application/vnd.samanage.v2.0+#{self.content_type}#{verbose}",
        'Content-type'  => "application/#{self.content_type}",
        'X-Samanage-Authorization' => 'Bearer ' + self.token
      })
      @options = {
        headers: headers,
        payload: payload
      }
      full_path = self.base_url + path
      retries = 0
      begin
        case http_method.to_s.downcase
        when 'get'
          api_call = self.class.get(full_path, headers: headers)
        when 'post'
          api_call = self.class.post(full_path, query: payload, headers: headers)
        when 'put'
          api_call = self.class.put(full_path, query: payload, headers: headers)
        when 'delete'
          api_call = self.class.delete(full_path, query: payload, headers: headers)
        else
          raise Samanage::Error.new(response: {response: 'Unknown HTTP method'})
        end
      rescue Errno::ECONNREFUSED, Net::OpenTimeout, Errno::ETIMEDOUT, OpenSSL::SSL::SSLError => e
        puts "Error:[#{e.class}] #{e} -  Retry: #{retries}/#{self.max_retries}"
        sleep 3
        retries += 1
        retry if retries < self.max_retries
        error = e
        response = e.class
        raise Samanage::InvalidRequest.new(error: error, response: response)
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
        begin
          response[:data] = JSON.parse(api_call.body)
        rescue JSON::ParserError => e
          response[:data] = api_call.body
          puts "** Warning **#{e.class}"
          puts e
        end
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
