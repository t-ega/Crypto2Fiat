module API
  module V1
    class Payment < Grape::API
      namespace :payment do
        namespace :confrim do
          desc "Get the status of an ongoing payment"
          route_param :id, type: String do
            get do
              transaction_id = params[:id]

              status, result =
                Transactions::StatusManager.new(transaction_id).call

              render_error(errors: result, code: 400) if status != :ok
              render_success(data: result)
            end
          end
        end
      end
    end
  end
end

{
  "id" => "t5b23jmi",
  "type" => "coin_address",
  "currency" => "usdt",
  "amount" => "200.0",
  "fee" => "0.0",
  "txid" =>
    "0x63a669d7279553eda06707e854d090a03a2628f3a3799354545c3537c8a507c9",
  "status" => "accepted",
  "reason" => nil,
  "created_at" => "2024-05-24T20:33:04.000Z",
  "done_at" => nil,
  "wallet" => {
    "id" => "5cg3i6vr",
    "name" => "USDT Tether",
    "currency" => "usdt",
    "balance" => "9.2831815942067831",
    "locked" => "0.0",
    "staked" => "0.0",
    "user" => {
      "id" => "vhq6ol3x",
      "sn" => "QDXLAN5SLCR",
      "email" => "beniyoke@gmail.com",
      "reference" => nil,
      "first_name" => "TEGA",
      "last_name" => "AKPOJIYOVWI",
      "display_name" => nil,
      "created_at" => "2020-07-04T08:59:38.000Z",
      "updated_at" => "2024-06-10T12:21:01.000Z"
    },
    "converted_balance" => "13656.024284157888279255",
    "reference_currency" => "ngn",
    "is_crypto" => true,
    "created_at" => "2020-07-04T08:59:38.000Z",
    "updated_at" => "2024-05-31T11:57:50.000Z",
    "blockchain_enabled" => true,
    "default_network" => "bep20",
    "networks" => [
      {
        "id" => "bep20",
        "name" => "Binance Smart Chain",
        "deposits_enabled" => true,
        "withdraws_enabled" => true
      },
      {
        "id" => "erc20",
        "name" => "Ethereum Network",
        "deposits_enabled" => true,
        "withdraws_enabled" => true
      },
      {
        "id" => "trc20",
        "name" => "Tron Network",
        "deposits_enabled" => true,
        "withdraws_enabled" => true
      },
      {
        "id" => "polygon",
        "name" => "Polygon Network",
        "deposits_enabled" => true,
        "withdraws_enabled" => false
      },
      {
        "id" => "solana",
        "name" => "Solana Network",
        "deposits_enabled" => true,
        "withdraws_enabled" => false
      }
    ],
    "deposit_address" => "0xF28670D57a706aAcb32be3D056766c61df279dDC",
    "destination_tag" => nil
  },
  "user" => {
    "id" => "vhq6ol3x",
    "sn" => "QDXLAN5SLCR",
    "email" => "beniyoke@gmail.com",
    "reference" => nil,
    "first_name" => "TEGA",
    "last_name" => "AKPOJIYOVWI",
    "display_name" => nil,
    "created_at" => "2020-07-04T08:59:38.000Z",
    "updated_at" => "2024-06-10T12:21:01.000Z"
  },
  "payment_transaction" => {
    "status" => "confirmed",
    "confirmations" => 1,
    "required_confirmations" => 1
  },
  "payment_address" => {
    "id" => "d4hlx75u",
    "reference" => nil,
    "currency" => "usdt",
    "address" => "0xF28670D57a706aAcb32be3D056766c61df279dDC",
    "network" => "bep20",
    "user" => {
      "id" => "vhq6ol3x",
      "sn" => "QDXLAN5SLCR",
      "email" => "beniyoke@gmail.com",
      "reference" => nil,
      "first_name" => "TEGA",
      "last_name" => "AKPOJIYOVWI",
      "display_name" => nil,
      "created_at" => "2020-07-04T08:59:38.000Z",
      "updated_at" => "2024-06-10T12:21:01.000Z"
    },
    "destination_tag" => nil,
    "total_payments" => nil,
    "created_at" => "2022-07-15T14:01:35.000Z",
    "updated_at" => "2022-07-15T14:01:38.000Z"
  }
}
