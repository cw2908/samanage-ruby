module Samanage
	class Api
		# Get requester from value (email)
		def get_requester_id(value: nil)
			api_call = self.execute(path: "requesters.json?name=#{value}")
			requester = api_call[:data].size == 1 ? api_call[:data][0] : nil
			requester
		end
	end
end