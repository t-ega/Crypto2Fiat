class AddPayoutStartedAtToTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :deposit_confirmed_at, :datetime
    add_column :transactions, :payout_confirmed_at, :datetime
    add_column :transactions, :payout_reference, :string
    add_column :transactions, :failed_at, :datetime
  end
end
