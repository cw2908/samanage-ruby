module Samanage
	class Api
		def get_requester_id(value: )
			api_call = self.execute(path: "requesters.json?name=#{value}")
			requester = api_call[:data].size == 1 ? api_call[:data][0] : nil
			requester
		end
	end
end