require 'samanage'
require 'faker'

describe Samanage::Api do
  context 'Site' do
    before(:all) do
      TOKEN ||= ENV['SAMANAGE_TEST_API_TOKEN']
      @samanage = Samanage::Api.new(token: TOKEN)
      @incidents = @samanage.incidents
    end
    it 'Returns empty when no time tracks for valid incident' do
      incidents_without_time_tracks = @incidents.select{|incident| incident['time_tracks'].to_a.empty?}
      incident_id = incidents_without_time_tracks.sample.dig('id')
      time_tracks = @samanage.time_tracks(incident_id: incident_id)
      expect(time_tracks).to be_an(Array)
      expect(time_tracks).to be_empty
    end
    it 'creates a time_track' do
      incident_id = @incidents.sample.dig('id')
      name = [Faker::NatoPhoneticAlphabet.code_word,Faker::NatoPhoneticAlphabet.code_word,Faker::NatoPhoneticAlphabet.code_word].join(' ')
      minutes = rand(1000)
      request = @samanage.create_time_track(incident_id: incident_id, payload: {
        time_track: {
          name: name,
          minutes_parsed: minutes
        }
      })
      expect(request[:code]).to eq(201).or(200)
      expect(request[:data].dig('minutes')).to eq(minutes)
    end
    it 'Finds time tracks' do
      incidents_with_time_tracks = @incidents.select{|incident| !incident['time_tracks'].to_a.empty?}
      incident_id = incidents_with_time_tracks.sample.dig('id')
      time_tracks = @samanage.time_tracks(incident_id: incident_id)
      expect(time_tracks).to be_an(Array)
      expect(time_tracks).not_to be_empty
    end
    it 'updates a time_track' do
      incidents_with_time_tracks = @incidents.select{|incident| !incident['time_tracks'].to_a.empty?}
      incident_id = incidents_with_time_tracks.sample.dig('id')
      time_tracks = @samanage.time_tracks(incident_id: incident_id)
      time_track_id = time_tracks.sample.dig('id')
      name = [Faker::NatoPhoneticAlphabet.code_word,Faker::NatoPhoneticAlphabet.code_word,Faker::NatoPhoneticAlphabet.code_word].join(' ')
      minutes = rand(1000)
      request = @samanage.update_time_track(time_track_id: time_track_id, incident_id: incident_id, payload: {
        time_track: {
          name: name,
          minutes_parsed: minutes
        }
      })
      expect(request[:code]).to eq(200).or(201)
    end
    it 'fails when invalid incident' do
      expect { @samanage.time_tracks(incident_id: rand(100)) }.to raise_error(Samanage::NotFound)
    end
  end
end