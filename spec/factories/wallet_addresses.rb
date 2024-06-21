FactoryBot.define do
  factory :wallet_address do
    address { "address" }
    network { "network" }
    address_id { "address_id" }
    currency { "currency" }
  end
end
