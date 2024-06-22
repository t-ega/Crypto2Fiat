FactoryBot.define do
  factory :transaction do
    from_currency { "eth" }
    to_currency { "ngn" }
    from_amount { 1 }
    receipient_email { "email@example.com" }
    payment_address { "adddress" }
    public_id { "pub_id" }
    network { "bep20" }
  end
end
