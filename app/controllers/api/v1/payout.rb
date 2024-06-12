module API
  module V1
    class Payout < Grape::API
      namespace :payouts do
        desc "Get details of all the supported banks"

        get :list_banks do
          Rails
            .cache
            .fetch("list_banks", expires_in: 3.hours) do
              status, result = Kora::ListBanks.new.call
              render_error(errors: result, code: 400) if status != :ok
              render_success(data: result)
            end
        end
      end
    end
  end
end
