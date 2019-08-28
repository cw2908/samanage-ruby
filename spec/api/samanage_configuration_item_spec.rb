# frozen_string_literal: true

require "samanage"
require "faker"

describe Samanage::Api do
  context "configuration_items" do
    describe "API Functions" do
      before(:all) do
        TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
        @samanage = Samanage::Api.new(token: TOKEN)
        @configuration_items = @samanage.configuration_items(options: { verbose: true })
        @users = @samanage.get_users[:data]
      end
      it "get_configuration_items: it returns API call of configuration_items" do
        api_call = @samanage.get_configuration_items
        expect(api_call).to be_a(Hash)
        expect(api_call[:total_count]).to be_an(Integer)
        expect(api_call).to have_key(:response)
        expect(api_call).to have_key(:code)
      end
      it "collect_configuration_items: collects array of configuration_items" do
        configuration_item_count = @samanage.get_configuration_items[:total_count]
        expect(@configuration_items.size).to eq(configuration_item_count)
        expect(@configuration_items).to be_an(Array)
      end
      it "create_configuration_item(payload: json): creates a configuration_item" do
        users_email = @users.sample["email"]
        configuration_item_name = Faker::Device.model_name
        json = {
          configuration_item: {
            name: configuration_item_name,
            priority: "Low",
            description: "Description",
            state: "Operational",
            user: { email: users_email },
          }
        }
        configuration_item_create = @samanage.create_configuration_item(payload: json)

        expect(configuration_item_create[:data]["id"]).to be_an(Integer)
        expect(configuration_item_create[:data]["name"]).to eq(configuration_item_name)
        expect(configuration_item_create[:code]).to eq(200).or(201)
      end
      it "create_configuration_item: fails if no name/title" do
        json = {
          configuration_item: {
            description: "Description"
          }
        }
        expect { @samanage.create_configuration_item(payload: json) }.to raise_error(Samanage::InvalidRequest)
      end
      it "find_configuration_item: returns a configuration_item card by known id" do
        sample_id = @configuration_items.sample["id"]
        configuration_item = @samanage.find_configuration_item(id: sample_id)
        expect(configuration_item[:data]["id"]).to eq(sample_id)  # id should match found configuration_item
        expect(configuration_item[:data]).to have_key("name")
        expect(configuration_item[:data]).to have_key("id")
      end
      it "find_configuration_item: returns more keys with layout=long" do
        sample_id = @configuration_items.sample["id"]
        layout_regular_configuration_item = @samanage.find_configuration_item(id: sample_id)
        layout_long_configuration_item = @samanage.find_configuration_item(id: sample_id, options: { layout: "long" })

        expect(layout_long_configuration_item[:data]["id"]).to eq(sample_id)  # id should match found configuration_item
        expect(layout_long_configuration_item[:data].keys.size).to be > (layout_regular_configuration_item.keys.size)
        expect(layout_long_configuration_item[:data].keys - layout_regular_configuration_item[:data].keys).to_not be([])
      end
      it "update_configuration_item: update_configuration_item by id" do
        sample_configuration_item = @configuration_items.reject { |i| ["Closed", "Resolved"].include? i["state"] }.sample
        sample_id = sample_configuration_item["id"]
        description = (0...500).map { ("a".."z").to_a[rand(26)] }.join
        configuration_item_json = {
          configuration_item: {
            description: description
          }
        }
        configuration_item_update = @samanage.update_configuration_item(payload: configuration_item_json, id: sample_id)
        # expect(configuration_item_update[:data]['description']).to eq(description) # configuration_item bug #00044569
        expect(configuration_item_update[:code]).to eq(200).or(201)
      end
      it 'finds more data for option[:layout] = "long"' do
        full_layout_configuration_item_keys = @samanage.configuration_items(options: { layout: "long" }).first.keys
        basic_configuration_item_keys = @samanage.configuration_items.sample.keys
        expect(basic_configuration_item_keys.size).to be < full_layout_configuration_item_keys.size
      end
      it "deletes a valid configuration_item" do
        sample_configuration_item_id = @configuration_items.sample["id"]
        configuration_item_delete = @samanage.delete_configuration_item(id: sample_configuration_item_id)
        expect(configuration_item_delete[:code]).to eq(200).or(201)
      end
    end
  end
end
