# frozen_string_literal: true

require "samanage"
require "faker"
describe Samanage::Api do
  context "Hardware" do
    describe "API Functions" do
      before(:all) do
        TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
        @samanage = Samanage::Api.new(token: TOKEN)
        @hardwares = @samanage.get_hardwares[:data]
      end
      it "get_hardwares: it returns API call of hardwares" do
        api_call = @samanage.get_hardwares
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it "collect_hardwares: collects array of hardwares" do
        hardware_count = @samanage.get_hardwares[:total_count]
        @hardwares = @samanage.hardwares
        expect(@hardwares).to be_an(Array)
        expect(@hardwares.size).to eq(hardware_count)
      end
      it "create_hardware(payload: payload): creates a hardware" do
        3.times do
          hardware_name = Faker::Science.scientist
          serial_number = [Faker::Device.serial,Faker::Device.serial,Faker::Device.serial].join('-')
          payload = {
            hardware: {
              name: hardware_name,
              bio: { ssn: serial_number },
            }
          }
          hardware_create = @samanage.create_hardware(payload: payload)

          expect(hardware_create[:data]["id"]).to be_an(Integer)
          expect(hardware_create[:data]["name"]).to eq(hardware_name)
          expect(hardware_create[:code]).to eq(200).or(201)
        end
      end
      it "create_hardware: fails if no serial" do
          hardware_name = "samanage-ruby-#{(rand * 10**10).ceil}"
          payload = {
            hardware: {
              name: hardware_name,
            }
          }
          expect {
            @samanage.create_hardware(payload: payload)
          }.to raise_error(Samanage::InvalidRequest)
      end
      it "find_hardware: returns a hardware card by known id" do
        @hardwares = @samanage.get_hardwares[:data]
        sample_id = @hardwares.sample["id"]
        hardware = @samanage.find_hardware(id: sample_id)

        expect(hardware[:data]["id"]).to eq(sample_id)  # id should match found hardware
        expect(hardware[:data]).to have_key("name")
        expect(hardware[:data]).to have_key("serial_number")
        expect(hardware[:data]).to have_key("id")
      end
      it "find_hardware: returns nothing for an invalid id" do
        sample_id = (0..10).entries.sample
        expect {
          @samanage.find_hardware(id: sample_id)
        }.to raise_error(Samanage::NotFound)  # id should match found hardware
      end

      it "finds_hardwares_by_serial" do
        sample_hardware = @samanage.get_hardwares[:data].sample
        sample_serial_number = sample_hardware["serial_number"]
        puts "sample_serial_number: #{sample_serial_number}"
        found_assets = @samanage.find_hardwares_by_serial(serial_number: sample_serial_number)
        found_sample = found_assets[:data].sample
        puts "found_sample #{found_sample.class}"
        puts "found_sample #{found_sample.count}"
        expect(sample_serial_number).not_to be(nil)
        expect(found_sample["serial_number"]).not_to be(nil)
        expect(found_sample["serial_number"]).to eq(sample_serial_number)
        # expect(sample_id).to eq(found_assets[:data].first.dig('id'))
      end
      it "update_hardware: update_hardware by id" do
        @hardwares = @samanage.get_hardwares[:data]
        sample_id = @hardwares.sample["id"]
        new_name = [Faker::Device.manufacturer, Faker::Device.platform].join("-")
        payload = {
          hardware: {
            name: new_name,
            tag: Faker::Books::Dune.saying,
            asset_id: Faker::Space.moon
          }
        }
        hardware_update = @samanage.update_hardware(payload: payload, id: sample_id)
        expect(hardware_update[:data]["name"]).to eq(new_name)
        expect(hardware_update[:code]).to eq(200).or(201)
      end
      it "deletes a valid hardware" do
        @hardwares = @samanage.get_hardwares[:data]
        sample_hardware_id = @hardwares.sample["id"]
        hardware_delete = @samanage.delete_hardware(id: sample_hardware_id)
        expect(hardware_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
