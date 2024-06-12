module API
  class Base < Grape::API
    prefix :api
    format :json

    mount API::V1::Base

    route :any, "*path" do
      all_paths = API::V1::Base.routes.map { |route| route.path }
      puts all_paths
      error!(
        {
          success: false,
          message: "The requested resource could not be found",
          errors: []
        },
        404
      )
    end
  end
end
