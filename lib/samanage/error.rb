module Samanage
	class Error < StandardError
		attr_accessor :status_code, :response, :error
		def initialize(error: nil, response: {})
			self.status_code = response[:code]
			self.response = response[:data] ||= response[:response]
			self.error = error
			puts "Response: #{self.status_code}: #{self.response}"
		end

	end

	class AuthorizationError < Error
	end

	class InvalidRequest < Error
	end

	class NotFound < Error
	end
end