module Kora
  class BaseClient
    attr_reader :http_client

    def initialize
      kora_api_key = Rails.application.credentials.kora_api_key
      base_url = "https://api.korapay.com"
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{kora_api_key}"
      }
      @http_client =
        Faraday.new(url: base_url, headers: headers) do |faraday|
          faraday.response :json
          faraday.response :raise_error
        end
    end

    def get_request(url, authorization: nil)
      http_client.headers[
        "Authorization"
      ] = "Bearer #{authorization}" if authorization.present?

      response = http_client.get(url)
      response.body.with_indifferent_access
    end

    def post_request(url, data)
      response = http_client.post(url)
      puts "Response: #{response.body}"
      response.body.with_indifferent_access
    end
  end
end
