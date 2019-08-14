# frozen_string_literal: true

module Samanage
  class Api
    def time_tracks(incident_id:)
      self.execute(path: "incidents/#{incident_id}/time_tracks.json")[:data]
    end

    def create_time_track(incident_id:, payload:)
      self.execute(path: "incidents/#{incident_id}/time_tracks.json", http_method: "post", payload: payload)
    end

    def update_time_track(incident_id:, time_track_id:, payload:)
      self.execute(path: "incidents/#{incident_id}/time_tracks.json")
    end
  end
end
