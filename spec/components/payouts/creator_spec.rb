require "rails_helper"

RSpec.describe Payouts::Creator do
  let(:payment_address) { "123" }
  let(:wallet) { create(:wallet_address) }
  let(:usdt_equivalent) { 1 } # Mock that the usdt equivalent of any currency is 1
  let(:price_ticker) do
    instance_double(Market::Ticker, call: [:ok, usdt_equivalent])
  end

  let (:wallet_fetcher) {
    instance_double(Wallets::Fetcher, call: [:ok, wallet])
  }

  before do
    allow(Wallets::Fetcher).to receive(:new).and_return(wallet_fetcher)
    allow(Market::Ticker).to receive(:new).and_return(price_ticker)
  end

  describe "when called" do
    it "should create a payout successfully" do
      account_details = { code: "000", account: "00000000" }
      crypto_amount_to_send = 1

      status, result =
        Payouts::Creator.new(
          account_details: account_details,
          from_amount: crypto_amount_to_send,
          from_currency: wallet.currency,
          receipient_email: "email@example.com"
        ).call

      wallet.reload

      expect(status).to eq(:ok)
      expect(wallet.in_use).to eq(true)
      expect(result.public_id).to be_present
      expect(result.status).to eq("initiated")
      expect(result.from_amount).to eq(crypto_amount_to_send)
      expect(result.account_details.symbolize_keys).to eq(account_details)
    end

    describe "authentication constraints" do
      it "should not approve a payout for unauthenticated users processing more than the allowed amount" do
        # Assume a max USDT VOL of 5USDT for the free tier users
        stub_const("Payouts::FREE_TIER_MAX_USDT_VOL", 5)

        from_currency = "eth"
        eth_usdt_equivalent = 1

        price_ticker =
          instance_double(Market::Ticker, call: [:ok, eth_usdt_equivalent])

        allow(Market::Ticker).to receive(:new).and_return(price_ticker)

        account_details = { code: "000", account: "00000000" }
        crypto_amount_to_send = 100

        status, result =
          Payouts::Creator.new(
            account_details: account_details,
            from_amount: crypto_amount_to_send,
            from_currency: from_currency,
            receipient_email: "email@example.com",
            sender_email: nil # empty means no authentication credentials
          ).call

        expect(status).to eq(:error)
        expect(result).to include("Unable to process amount")
      end

      it "should approve any amount of payout for an authenticated user" do
        # Assume a max USDT VOL of 5USDT for the free tier users
        stub_const("Payouts::FREE_TIER_MAX_USDT_VOL", 5)

        wallet = create(:wallet_address, currency: "eth")
        eth_usdt_equivalent = 1

        price_ticker =
          instance_double(Market::Ticker, call: [:ok, eth_usdt_equivalent])

        wallet_fetcher_stub =
          instance_double(Wallets::Fetcher, call: [:ok, wallet])

        allow(Wallets::Fetcher).to receive(:new).and_return(wallet_fetcher_stub)

        allow(Market::Ticker).to receive(:new).and_return(price_ticker)

        account_details = { code: "000", account: "00000000" }
        crypto_amount_to_send = 100

        user = create(:user)

        status, result =
          Payouts::Creator.new(
            account_details: account_details,
            from_amount: crypto_amount_to_send,
            from_currency: wallet.currency,
            receipient_email: "jon@example.com",
            sender_email: user.email
          ).call

        wallet.reload

        expect(status).to eq(:ok)
        expect(wallet.in_use).to eq(true)
        expect(result.public_id).to be_present
        expect(result.status).to eq("initiated")
        expect(result.from_amount).to eq(crypto_amount_to_send)
        expect(result.account_details.symbolize_keys).to eq(account_details)
      end
    end

    it "should not create a payout if there are no unlocked wallets" do
      wallet = create(:wallet_address)

      wallet_fetcher = instance_double(Wallets::Fetcher, call: [:ok, wallet]) # Wallet is originally not in use

      # Implementing a scenairo where a wallet address was fetched immediately
      #  before it was locked for use by another process
      wallet.lock_for_deposit!

      # Now the wallet fetcher would return a wallet that was previous unlocked but now its locked
      allow(Wallets::Fetcher).to receive(:new).and_return(wallet_fetcher)

      account_details = { code: "000", account: "00000000" }
      crypto_amount_to_send = 1

      expect {
        status, result =
          Payouts::Creator.new(
            account_details: account_details,
            from_amount: crypto_amount_to_send,
            from_currency: wallet.currency,
            receipient_email: "email@example.com"
          ).call

        expect(status).to eq(:error)
        expect(result).to eq("Wallet address is already in use!")
      }.not_to change { Transaction.count }
    end
  end
end
