# frozen_string_literal: true

module Samanage
  class Api
    # Get requester from value (email)
    def get_requester_id(value:)
      api_call = self.execute(path: "requesters.json?name=#{value}")
      api_call[:data].size == 1 ? api_call[:data][0] : nil
    end
  end
end
