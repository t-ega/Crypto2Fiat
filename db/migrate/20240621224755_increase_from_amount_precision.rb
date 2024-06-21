class IncreaseFromAmountPrecision < ActiveRecord::Migration[7.1]
  def change
    change_column :transactions, :from_amount, :decimal, precision: 10, scale: 5
  end
end
