class CreateTransaction < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :from_currency
      t.string :to_currency
      t.decimal :from_amount, precision: 10, scale: 3
      t.decimal :to_amount, precision: 10, scale: 3
      t.string :status
      t.string :receipient_email
      t.string :sender_email
      t.string :payment_address
      t.string :public_id
      t.string :network
      t.jsonb :account_details

      t.timestamps
    end
  end
end
