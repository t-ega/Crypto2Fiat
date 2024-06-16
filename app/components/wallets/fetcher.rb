module Wallets
  # The wallets addresses are fetched in 3 steps.
  # Step 1: The system would check for already generated addresses that have a **wallet address** and
  # that they are not in use. If none found move to step 2
  # Step 2: Search for any wallet address that don't yet have an address tied to them
  # e.g they were freshly created and they only have their ID. If one is found then we can
  # call the wallets API to check if their address is ready
  # Step 3: If this step is reached, it means that there is no available address then generate one

  class Fetcher
    attr_reader :currency

    def initialize(currency)
      @currency = currency
    end

    def call
      wallet_address = find_valid_address || fetch_and_update_address
      return :ok, wallet_address if wallet_address

      # # Generate a new one
      CreateWalletAddressJob.perform_later(currency)
      [:pending, "Generating wallet address"]
    end

    private

    def wallet_addresses
      WalletAddress.currency(currency).not_in_use
    end

    def find_valid_address
      wallet_addresses.where.not(address: nil).take
    end

    def fetch_and_update_address
      wallet_without_address = wallet_addresses.where(address: nil).take
      return if wallet_without_address.blank?

      fetched_address =
        Quidax::Wallets.new.fetch_wallet_address_by_id(
          wallet_without_address.address_id
        )

      if fetched_address[:address]
        wallet_without_address.update(address: fetched_address[:address])
        wallet_without_address.reload
      end
    end
  end
end
