# frozen_string_literal: true

module Samanage
  class Error < StandardError
    attr_accessor :status_code, :response, :error

    def initialize(error: nil, response: {}, options: {}, request_path: "")
      self.error = error
      if response.class == Hash
        self.status_code = response[:code]
        self.response = response[:data] ||= response[:response]
      else
        self.status_code = nil
        self.response = response
      end
      puts "[Error] #{self.status_code}: #{self.response} #{request_path} headers: #{response[:headers]}"
      nil
    end
  end

  # API Errors
  class SamanageError < Error; end

  class AuthorizationError < SamanageError; end

  class InvalidRequest < SamanageError; end

  class NotFound < SamanageError; end
end
