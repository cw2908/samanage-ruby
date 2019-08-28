# frozen_string_literal: true

require "httparty"
require "open-uri"
module Samanage
  class Api
    include HTTParty
    attr_accessor :datacenter, :content_type, :base_url, :token, :custom_forms,
                  :authorized, :admins, :max_retries, :sleep_time
    PATHS = {
      attachment: "attachments.json",
      category: "categories.json",
      change: "changes.json",
      contract: "contracts.json",
      configuration_item: "configuration_items.json",
      custom_field: "custom_fields.json",
      custom_fields: "custom_fields.json",
      custom_form: "custom_forms.json",
      custom_forms: "custom_forms.json",
      department: "departments.json",
      group: "groups.json",
      hardware: "hardwares.json",
      incident: "incidents.json",
      mobile: "mobiles.json",
      other_asset: "other_assets.json",
      problem: "problems.json",
      purchase_order: "purchase_orders.json",
      release: "releases.json",
      site: "sites.json",
      task: "tasks.json",
      solution: "solutions.json",
      user: "users.json",
      vendor: "vendors.json"
    }.freeze
    # Development mode forces authorization & pre-populates admins and custom forms / fields
    # datacenter should equal 'eu' or blank
    def initialize(token:, datacenter: nil, development_mode: false,
      max_retries: 3, content_type: "json", sleep_time: 5)
      self.token = token
      datacenter = nil if !datacenter.nil? && datacenter.to_s.downcase != "eu"
      self.datacenter ||= datacenter.to_s.downcase
      self.base_url = "https://api#{self.datacenter.to_s.downcase}.samanage.com/"
      self.content_type = content_type || "json"
      self.admins = []
      self.max_retries = max_retries
      self.sleep_time = sleep_time
      if development_mode
        authorize if authorized? != true
        self.custom_forms = organize_forms
        self.admins = list_admins
      end
    end

    def authorized?
      authorized
    end

    # Check "oken against api.json"
    def authorize
      execute(path: "api.#{content_type}")
      self.authorized = true
    end

    # Calling execute without a method defaults to GET
    def execute(http_method: "get", path: nil, payload: nil, verbose: nil, headers: {}, options: {}, multipart: false)
      if payload.class == Hash && content_type == "json"
        begin
          payload = payload.to_json if path != "attachments.json"
        rescue StandardError => e
          puts "Invalid JSON: #{payload.inspect}"
          raise Samanage::Error.new(error: e, response: nil, options: options)
        end
      end
      verbose = "?layout=long" unless verbose.nil?

      headers = {
        "Accept" => "application/vnd.samanage.v2.1+#{content_type}#{verbose}",
        "Content-Type" => "application/#{content_type}",
        "X-Samanage-Authorization" => "Bearer " + self.token
      }.merge(headers)
      options = options.except(:verbose)
      full_path = base_url + path
      retries = 0
      begin
        case http_method.to_s.downcase
        when "get"
          api_call = self.class.get(full_path, headers: headers, query: options)
        when "post"
          api_call = self.class.post(full_path, multipart: multipart,  body: payload, headers: headers, query: options)
        when "put"
          api_call = self.class.put(full_path, body: payload, headers: headers, query: options)
        when "delete"
          api_call = self.class.delete(full_path, body: payload, headers: headers, query: options)
        else
          raise Samanage::Error.new(response: { response: "Unknown HTTP method" }, options: options)
        end
      rescue Errno::ECONNREFUSED, Net::OpenTimeout, Errno::ETIMEDOUT, Net::ReadTimeout, OpenSSL::SSL::SSLError,
            Errno::ENETDOWN, Errno::ECONNRESET, Errno::ENOENT, EOFError, Net::HTTPTooManyRequests, SocketError => e
        retries += 1
        if retries < max_retries
          puts "[Warning] #{e.class}: #{e} -  Retry: #{retries}/#{max_retries}"
          sleep sleep_time
          retry
        else
          error = e
          response = e.class
          raise Samanage::InvalidRequest.new(error: error, response: response, options: options)
        end
      rescue StandardError => e
        retries += 1
        if retries < max_retries
          puts "[Warning] #{e.class}: #{e} -  Retry: #{retries}/#{max_retries}"
          sleep sleep_time
          retry
        else
          error = e
          response = e.class
          raise Samanage::InvalidRequest.new(error: error, response: response, options: options)
        end

      end

      response = {}
      response[:code] = api_call.code.to_i
      response[:json] = api_call.body
      response[:response] = api_call
      response[:headers] = api_call.headers
      response[:total_pages] = api_call.headers["X-Total-Pages"].to_i
      response[:total_pages] = 1 if response[:total_pages] == 0
      response[:total_count] = api_call.headers["X-Total-Count"].to_i

      # Error cases
      case response[:code]
      when 200..201
        begin
          response[:data] = JSON.parse(api_call.body)
        rescue JSON::ParserError => e
          response[:data] = api_call.body
          puts "[Warning] #{e.class}: #{e}" unless path.match?("send_activation_email")
        end
        response
      when 401
        response[:data] = api_call.body
        error = response[:response]
        self.authorized = false
        raise Samanage::AuthorizationError.new(error: error, response: response, options: options)
      when 404
        response[:data] = api_call.body
        error = response[:response]
        raise Samanage::NotFound.new(error: error, response: response, options: options)
      when 422
        response[:data] = api_call.body
        error = response[:response]
        raise Samanage::InvalidRequest.new(error: error, response: response, options: options)
      when 429
        response[:data] = api_call.body
        error = response[:response]
        raise Samanage::InvalidRequest.new(error: error, response: response, options: options)
      else
        response[:data] = api_call.body
        error = response[:response]
        raise Samanage::InvalidRequest.new(error: error, response: response, options: options)
      end
    end

    def set_params(options:)
      options[:audit_archive] = options[:audit_archive] || options[:audit_archives] if options[:audit_archives]
      URI.encode_www_form(options.except(:verbose))
    end

    # Return all admins in the account
    def list_admins
      admin_role_id = execute(path: "roles.json")[:data]
        .find { |role| role["name"] == "Administrator" }
        .dig("id")
      admin_path = "users.json?role=#{admin_role_id}"
      admins.push(
        execute(path: admin_path)[:data]
          .map { |u| u["email"] }
      ).flatten
    end
  end
end
