module Quidax
  class BaseClient
    attr_reader :http_client

    def initialize
      quidax_api_key = Rails.application.credentials.quidax_api_key
      headers = {
        "Content-Type" => "application/json",
        "Autorization" => "Bearer #{quidax_api_key}"
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
      puts "Response: #{response.body}"
      response.body.with_indifferent_access
    end
  end
end
