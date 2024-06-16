module Errors
  module Payouts
    class WalletAddressInUseError < BaseError
      def initialize(msg = "Wallet address is already in use!")
        super(msg)
      end
    end
  end
end
