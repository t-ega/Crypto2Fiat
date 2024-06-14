class CreateWalletAddress < ActiveRecord::Migration[7.1]
  def change
    create_table :wallet_addresses do |t|
      t.string :network
      t.string :address
      t.string :address_id
      t.string :currency
      t.datetime :last_used_at
      t.boolean :in_use, default: false

      t.timestamps
    end
  end
end
