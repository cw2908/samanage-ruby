module Samanage
	# Errors in gem
	class Error < StandardError
		attr_accessor :status_code, :response, :error
		def initialize(error: nil, response: {})
			if response.class == Hash
				self.status_code = response[:code]
				self.response = response[:data] ||= response[:response]
			else
				self.status_code = nil
				self.response = response
			end

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