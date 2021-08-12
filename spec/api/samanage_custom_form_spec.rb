# frozen_string_literal: true

require "samanage"

describe Samanage::Api do
  context "Custom Form" do
    describe "API Functions" do
      before(:all) do
        TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
        @controller = Samanage::Api.new(token: TOKEN, development_mode: true)
        @custom_forms = @controller.collect_custom_forms
      end
      it "collects all custom forms" do
        expect(@custom_forms).to be_an(Array)
      end
      it "Finds the forms for an form_name" do
        form_names = ["incident", "user"]
        form = @controller.form_for(form_name: form_names.sample)
        expect(form).to be_a(Hash)
      end
    end
  end
end
