class AuthenticationToken < ActiveRecord::Migration[7.1]
  def change
    create_table :authentication_tokens do |t|
      t.string :token
      t.references :user, foreign_key: true
      t.datetime :expires_at
      t.string :reason

      t.timestamps
    end

    add_column :users, :verified, :boolean
    add_column :users, :verified, :boolean
  end
end
