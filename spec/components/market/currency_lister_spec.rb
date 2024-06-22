require "rails_helper"

RSpec.describe Market::CurrencyLister do
  describe ".Call" do
    it "should list all the currencies available" do
      currencies = Market::CurrencyLister.call
      expect(currencies).to be_present
      expect(currencies.size).to be > 0 # There should be at least one currency per time
      expect(currencies[0].key?("currency")).to be_present
    end
  end
end
