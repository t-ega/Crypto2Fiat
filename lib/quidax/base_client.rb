module Quidax
  class BaseClient
    attr_reader :http_client

    def initialize
      quidax_api_key = Rails.application.credentials.quidax_api_key
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{quidax_api_key}"
      }
      base_url = "https://www.quidax.com/api/v1"

      @http_client =
        Faraday.new(url: base_url, headers: headers) do |faraday|
          faraday.response :json
          faraday.response :raise_error
        end
    end

    def get_request(url)
      response = http_client.get(url)
      response.body.with_indifferent_access
    end

    def post_request(url, data: {})
      response = http_client.post(url, data.to_json)
      response.body.with_indifferent_access
    end
  end
end
