desc "Fetch and populate internal wallet addresses from Quidax API"

namespace :quidax do
  task populate_wallet_addresses: :environment do
    allowed_currencies = Market::CurrencyLister.call
    task_name = "populate_wallet_addresses"

    puts "Started task #{task_name} at #{Time.current}"

    allowed_currencies.each do |currency|
      short_name = currency["short_name"].downcase

      status, result = Quidax::Wallets.new.fetch_wallet_addresses(short_name)

      if status != :ok
        puts "Unable to fetch address for #{short_name}. Reason:#{result}"
        break
      end

      result.each do |address|
        puts "Currency #{short_name}, Address: #{address["address"]}\n\n"

        wallet_address = address["address"]
        address_id = address["id"]
        currency = address["currency"]

        WalletAddress.find_or_create_by(
          address: wallet_address,
          currency: currency,
          address_id: address_id
        )
      end
    end

    puts "Finished #{task_name} at #{Time.current}"
  end
end
