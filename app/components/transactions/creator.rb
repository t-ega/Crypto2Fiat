module Transactions
  attr_reader :account_details,
              :wallet_address_id,
              :network,
              :sender_email,
              :receipient_email,
              :from_amount,
              :from_currency

  class Creator
    def initialize(
      account_details:,
      from_amount:,
      from_currency:,
      receipient_email:,
      sender_email: nil,
      wallet_address_id:,
      network: "bep20"
    )
      @account_details = account_details
      @from_amount = from_amount
      @from_currency = from_currency
      @receipient_email = receipient_email
      @wallet_address_id = wallet_address_id
      @network = network
      @sender_email = sender_email
    end

    def call
      transaction =
        Transaction.create(
          account_details: account_details,
          from_amount: from_amount,
          from_currency: from_currency,
          receipient_email: receipient_email,
          sender_email: sender_email,
          wallet_address_id: wallet_address_id,
          network: "bep20"
        )

      return :error, transaction.errors.full_messages if !transaction.valid?

      [:ok, transaction]
    end
  end
end
