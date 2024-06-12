module Kora
  class ResolveBank < BaseClient
    def initialize
      super
    end

    def call(bank_code:, account_number:)
      data = { code: bank_code, account: account_number }
      res = self.post_request(Endpoints::RESOLVE_BANK, data)

      return :ok, res[:data] if res[:data]
      [:error, res[:error]]
    rescue Faraday::Error => e
      [:error, e]
    end
  end
end
