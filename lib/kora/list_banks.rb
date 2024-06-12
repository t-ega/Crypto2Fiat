module Kora
  class ListBanks < BaseClient
    def initialize
      super
    end

    def call
      kora_public_key = Rails.application.credentials.kora_public_key

      res =
        self.get_request(Endpoints::LIST_BANKS, authorization: kora_public_key)

      return :ok, res[:data] if res[:data]
      [:error, res[:error]]
    rescue Faraday::Error => e
      [:error, e]
    end
  end
end
