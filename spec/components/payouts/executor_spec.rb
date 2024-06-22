require "rails_helper"

RSpec.describe Payouts::Executor do
  describe "when called" do
    # Mock the market price
    let(:market_price) { 1000 } # The current ticker for the currency pair ETHNGN
    let(:currency_pair) { "ethngn" }
    let(:account_details) { { code: "000", account: "000000" } }

    let(:transaction) do
      create(
        :transaction,
        account_details: account_details,
        from_currency: "eth",
        status: "deposit_confirmed",
        deposit_confirmed_at: Time.current, # Payout executor relies on this to process transaction
        to_currency: "ngn"
      )
    end

    let(:to_amount) { 500 }
    let(:kora_response) { { message: "success" } }

    # Return market_price when called
    let(:market_ticker) do
      instance_double(Market::Ticker, call: [:ok, market_price])
    end

    let(:kora_payout) do
      instance_double(Kora::Payouts::SinglePayout, call: [:ok, kora_response])
    end

    before do
      allow(Market::Ticker).to receive(:new).and_return(market_ticker)
      allow(Kora::Payouts::SinglePayout).to receive(:new).and_return(
        kora_payout
      )
    end

    it "should execute a payout that when the deposit has been confirmed" do
      status, _ = Payouts::Executor.new(transaction.public_id).call

      expect(status).to eq(:ok)

      transaction.reload
      expect(transaction.to_amount).to be_present
      expect(transaction.payout_reference).to be_present
      expect(transaction.status).to eq("payout_initiated")
    end

    describe "it fails" do
      it "should not create a payout if the transaction id is invalid" do
        status, result = Payouts::Executor.new("wrong_id").call

        expect(status).to eq(:error)
        expect(result).to include("Transaction not found")
      end

      it "should not create a payout that has not been confirmed" do
        transaction =
          create(
            :transaction,
            account_details: account_details,
            from_currency: "eth",
            to_currency: "ngn"
          )

        status, result = Payouts::Executor.new(transaction.public_id).call

        expect(status).to eq(:error)
        expect(result).to include("Transaction has not been confirmed")
      end

      it "should not create a payout that has already been completed" do
        transaction =
          create(
            :transaction,
            account_details: account_details,
            from_currency: "eth",
            status: "payout_completed",
            deposit_confirmed_at: 1.minutes.ago,
            payout_confirmed_at: Time.current,
            to_currency: "ngn"
          )

        status, result = Payouts::Executor.new(transaction.public_id).call

        expect(status).to eq(:error)
        expect(result).to include("Payout already executed")
      end
    end
  end
end
