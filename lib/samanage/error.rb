module Samanage
	# Errors in gem
	class Error < StandardError
		attr_accessor :status_code, :response, :error
		def initialize(error: nil, response: {})
			self.status_code = response.nil? ? nil : response[:code]
			self.response = response.nil? ? response : response[:data] ||= response[:response]
			self.error = error
			puts "[Error] #{self.status_code}: #{self.response}"
		end

	end

	# API Errors
	class SamanageError < Error; end

	class AuthorizationError < SamanageError; end

	class InvalidRequest < SamanageError; end

	class NotFound < SamanageError; end

end