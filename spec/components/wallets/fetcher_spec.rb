require "rails_helper"

RSpec.describe Wallets::Fetcher do
  describe "when called" do
    it "should find an address that is not locked" do
      wallet_currency = "eth"
      wallet_not_in_use = create(:wallet_address, currency: wallet_currency)
      wallet_in_use = create(:wallet_address, currency: wallet_currency)

      wallet_in_use.lock_for_deposit!
      status, result = Wallets::Fetcher.new(wallet_currency).call

      expect(status).to eq(:ok)

      # In reality any wallet address that is free may be picked.
      expect(result.address).to eq(wallet_not_in_use.address)
    end

    it "should fetch the wallet address if the a wallet is found but the wallet address is not present" do
      fetched_address = "fetched_address"
      mock_response = { address: fetched_address }

      quidax_wallet_mock =
        instance_double(
          Quidax::Wallets,
          fetch_wallet_address_by_id: [:ok, mock_response]
        )

      allow(Quidax::Wallets).to receive(:new).and_return(quidax_wallet_mock)

      wallet_currency = "eth"
      wallet = create(:wallet_address, address: nil, currency: wallet_currency)
      status, result = Wallets::Fetcher.new(wallet_currency).call

      expect(status).to eq(:ok)

      wallet.reload

      expect(wallet.address).to eq(fetched_address)
      expect(result.address).to eq(fetched_address)
    end
  end
end
