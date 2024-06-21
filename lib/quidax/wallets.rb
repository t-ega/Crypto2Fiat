module Quidax
  class Wallets < BaseClient
    def initialize
      super
    end

    def fetch_wallet_address(currency)
      handle_request("users/me/wallets/#{currency}/address", :get)
    end

    def fetch_deposits(currency)
      handle_request(
        "users/me/deposits?currency=#{currency}&state=accepted",
        :get
      )
    end

    def fetch_wallet_addresses(currency)
      handle_request("users/me/wallets/#{currency}/addresses", :get)
    end

    def fetch_wallet_address_by_id(address_id)
      handle_request("users/me/wallets/#{currency}/address/#{address_id}", :get)
    end

    def generate_wallet_address(currency)
      handle_request("users/me/wallets/#{currency}/addresses", :post)
    end

    private

    def handle_request(url, method)
      response = send_request(url, method)
      return :ok, response[:data] if response[:data]
      [:error, response[:error]]
    rescue Faraday::Error => e
      extra = {
        url: e.response[:request][:url_path],
        body: e.response[:request][:body],
        message: e.message
      }
      Rails.logger.error(
        "An error occurred while fetching data from Quidax API. Error: #{extra}"
      )
      [:error, "An error occurred"]
    end

    def send_request(url, method)
      case method
      when :get
        self.get_request(url)
      when :post
        self.post_request(url)
      else
        raise ArgumentError, "Unsupported HTTP method: #{method}"
      end
    end
  end
end
