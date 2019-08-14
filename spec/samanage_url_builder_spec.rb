# frozen_string_literal: true

require "samanage"
describe Samanage::UrlBuilder do
  context "Url Builder" do
    it "Strips down to id" do
      path = ["users.json", "hardwares/1234"]
      options = [
        { id: "1234" },
        { id: 12345, email: "abc@company.com" },
        { email: "abc", name: "Joe Doe" },
        { site: 0001, id: 1234 }
      ]
      5.times {
        url = Samanage::UrlBuilder.new(path: path.sample, options: options.sample).url
        expect(url).to be_a(String)
      }
    end
  end
end
