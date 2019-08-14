# frozen_string_literal: true

require "spec_helper"
describe Samanage do
  describe "Language" do
    context "when looking up language" do
      it "should find case-insensitive valid language codes" do
        valid_lang = "Czech"
        valid_lang_code = "cs"
        expect(Samanage.lookup_language(valid_lang)).to eq(valid_lang_code)
        expect(Samanage.lookup_language(valid_lang_code.upcase)).to eq(valid_lang_code)
      end
      it "should return nil for invalid language codes" do
        invalid_lang = "Mandalorian"
        invalid_lang_code = "zzzzzzzzz"
        expect(Samanage.lookup_language(invalid_lang)).to be(nil)
        expect(Samanage.lookup_language(invalid_lang_code)).to be(nil)
      end
    end
  end
end
