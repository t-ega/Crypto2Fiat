module Kora
  class ResolveBank < BaseClient
    def initialize
      super
    end

    def call(bank_code:, account_number:)
      data = { bank: bank_code, account: account_number }
      res = self.post_request(Endpoints::RESOLVE_BANK, data)

      return :ok, res[:data] if res[:data]
      [:error, res[:message]]
    rescue Faraday::Error => e
      Rails.logger.error("An error occurred. Error: #{e}")
      [:error, "An error occurred"]
    end
  end
end
