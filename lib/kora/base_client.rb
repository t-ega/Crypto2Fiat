module Kora
  class BaseClient
    BASE_URL = "https://api.korapay.com".freeze
    attr_reader :http_client

    def initialize
      kora_api_key = Rails.application.credentials.kora_api_key

      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{kora_api_key}"
      }
      @http_client =
        Faraday.new(url: BaseClient::BASE_URL, headers: headers) do |faraday|
          faraday.response :json
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
      response = http_client.post(url, data.to_json)
      response.body.with_indifferent_access
    end
  end
end
