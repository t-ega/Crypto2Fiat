class CreateWalletAddressJob < ApplicationJob
  queue_as :default

  def perform(currency)
    Rails.logger.info(
      "Started generating wallet address for #{currency} at #{Time.current}"
    )

    status, res = Quidax::Wallets.new.generate_wallet_address(currency)

    if status != :ok
      Rails.logger.error("Unable to generate address. Failed with: #{res}")
      return
    end

    wallet_address =
      WalletAddress.create(address_id: res[:id], currency: currency)

    if !wallet_address.valid?
      Rails.logger.error(
        "Unable to create address. Failed with: #{wallet_address.errors.full_messages}"
      )
    end
  end
end
