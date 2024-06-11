FactoryBot.define do
  factory :authentication_token do
    user { create(:user) }
    token { "randomtoken" }
  end
end
