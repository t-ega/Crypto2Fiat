require "rails_helper"

RSpec.describe Market::PriceCalculator do
  describe ".call" do
    let(:market_price) { 1000 } # The current ticker for the currency pair ETHNGN
    let(:currency_pair) { "ethngn" }

    # Return market_price when called
    let(:market_ticker) do
      instance_double(Market::Ticker, call: [:ok, market_price])
    end

    before do
      allow(Market::Ticker).to receive(:new).with(currency_pair).and_return(
        market_ticker
      )
    end

    it "should return the FIAT amount if the vol specified is the amount to be sent" do
      volume_to_send = 1
      quote_type = Market::PriceCalculator::VOLUME_TO_SEND
      service_charge_percentage = Market::PriceCalculator::PRICE_MARKUP
      price_per_unit = market_price * volume_to_send

      service_charge_amount = price_per_unit * service_charge_percentage
      price_after_service_charge =
        (price_per_unit - service_charge_amount).round # We don't send cents

      status, result =
        Market::PriceCalculator.new(
          currency_pair: currency_pair,
          vol: volume_to_send,
          quote_type: quote_type
        ).call

      expect(status).to eq(:ok)
      expect(result).to eq(price_after_service_charge)
    end

    it "should return the crypto currency equivalent if the vol specified is the amount to be received" do
      amount_to_receive = 1000
      quote_type = Market::PriceCalculator::VOLUME_TO_RECIEVE

      service_charge_percentage = Market::PriceCalculator::PRICE_MARKUP
      price_per_unit = market_price / amount_to_receive

      service_charge_amount = price_per_unit * service_charge_percentage
      expected_price_after_service_charge =
        price_per_unit + service_charge_amount

      status, result =
        Market::PriceCalculator.new(
          currency_pair: currency_pair,
          vol: amount_to_receive,
          quote_type: quote_type
        ).call

      expect(status).to eq(:ok)
      expect(result).to be_within(0.001).of(expected_price_after_service_charge)
    end
  end
end
