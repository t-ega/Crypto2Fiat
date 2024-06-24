module Transactions
  class Fetcher
    attr_reader :sender_email

    def initialize(email:)
      @sender_email = email
    end

    def call
      Transaction.where(sender_email: sender_email)
    end
  end
end
