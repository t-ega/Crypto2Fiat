class AddForeignKeyConstraintsToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
    add_foreign_key :transactions,
                    :users,
                    column: :sender_email,
                    primary_key: :email
  end
end
