module Samanage
  class Error < StandardError
    attr_accessor :status_code, :response, :error
    
    def initialize(error: nil, response: {}, options: {})
      self.error = error
      if response.class == Hash
        self.status_code = response[:code]
        self.response = response[:data] ||= response[:response]
      else
        self.status_code = nil
        self.response = response
      end
      puts "[Error] #{self.status_code}: #{self.response}"
      return
    end
  end

  # API Errors
  class SamanageError < Error; end

  class AuthorizationError < SamanageError; end

  class InvalidRequest < SamanageError; end

  class NotFound < SamanageError; end

end