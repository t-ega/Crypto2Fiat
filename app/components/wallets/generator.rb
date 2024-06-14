module Wallets
  class Generator
    attr_reader :currency

    def initialize(currency)
      @currency = currency
    end

    def call
      address = WalletAddress.not_in_use.find_by_currency(currency)
    end
  end
end
