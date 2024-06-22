require "rails_helper"

RSpec.describe CreateWalletAddressJob, type: :job do
  describe "when called" do
    currency = "eth"
    mock_generated_address = { id: "address_id", currency: "eth" }

    let(:mock_wallet_address) do
      instance_double(
        Quidax::Wallets,
        generate_wallet_address: [:ok, mock_generated_address]
      )
    end

    before do
      allow(Quidax::Wallets).to receive(:new).and_return(mock_wallet_address)
    end

    it "should create a wallet address" do
      expect {
        CreateWalletAddressJob.perform_now(currency)
        expect(WalletAddress.last.address_id).to eq(mock_generated_address[:id])
      }.to change { WalletAddress.count }.by(1)
    end
  end
end
