module Samanage
	class SamanageError < StandardError
		attr_accessor :status_code, :response, :error
		def initialize(error: nil, response: {})
			self.status_code = response[:code]
			self.response = response[:data] ||= response[:response]
			self.error = error
			puts "[Error] #{self.status_code}: #{self.response}"
		end

	end

	class AuthorizationError < SamanageError
	end

	class InvalidRequest < SamanageError
	end

	class NotFound < SamanageError
	end
end