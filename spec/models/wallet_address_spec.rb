require "rails_helper"

RSpec.describe WalletAddress, type: :model do
  describe "methods" do
    it "should lock a wallet for deposit if not in use" do
      wallet = create(:wallet_address)

      expect {
        wallet.lock_for_deposit!
        wallet.reload
      }.to change { wallet.in_use }.from(false).to(true)
    end

    it "should lock a wallet for deposit if in use and the max lock time has elasped" do
      wallet =
        create(:wallet_address, in_use: true, last_used_at: 30.minutes.ago)

      expect {
        wallet.lock_for_deposit!
        wallet.reload
      }.not_to raise_error
    end

    it "should raise an error if a wallet to be locked is in use" do
      wallet = create(:wallet_address)
      wallet.lock_for_deposit!

      expect {
        wallet.lock_for_deposit!
        wallet.reload
      }.to raise_error(Errors::Payouts::WalletAddressInUseError)
    end

    it "should unlock a wallet after use" do
      wallet = create(:wallet_address)
      wallet.lock_for_deposit!

      expect {
        wallet.unlock_for_deposit!
        wallet.reload
      }.to change { wallet.in_use }.from(true)
    end
  end
end
