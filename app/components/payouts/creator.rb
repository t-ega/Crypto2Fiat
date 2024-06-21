module Payouts
  class Creator
    attr_reader :account_details,
                :wallet_address_id,
                :network,
                :sender_email,
                :receipient_email,
                :from_amount,
                :from_currency,
                :transaction

    def initialize(
      account_details:,
      from_amount:,
      from_currency:,
      receipient_email:,
      sender_email: nil
    )
      @account_details = account_details
      @from_amount = from_amount
      @from_currency = from_currency
      @receipient_email = receipient_email
      @sender_email = sender_email
    end

    def call
      status, wallet = Wallets::Fetcher.new(from_currency).call
      return :error, wallet if status != :ok

      wallet.with_lock do
        # Lock the wallet for a deposit
        wallet.lock_for_deposit!

        @transaction =
          Transaction.create!(
            account_details: account_details,
            from_amount: from_amount,
            from_currency: from_currency,
            receipient_email: receipient_email,
            sender_email: sender_email,
            to_currency: "ngn",
            public_id: generate_public_id,
            payment_address: wallet.address,
            network: "bep20"
          )
      end

      [:ok, transaction]
    rescue Errors::Payouts::WalletAddressInUseError => e
      [:error, e.message]
    rescue ActiveRecord::RecordInvalid => invalid
      [:error, invalid.record.errors.full_messages]
    rescue StandardError => e
      Rails.logger.error(
        "An error occurred while creating payment. Error: #{e.inspect}"
      )
      [:error, "An error occurred while creating payment"]
    end

    private

    def generate_public_id
      SecureRandom.hex(5)
    end
  end
end
