FactoryBot.define do
  factory :wallet_address do
    address { "address" }
    network { "bep20" }
    address_id { "address_id" }
    currency { "eth" }
  end
end
