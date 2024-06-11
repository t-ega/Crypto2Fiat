class AuthenticationToken < ActiveRecord::Migration[7.1]
  def change
    create_table :authentication_tokens do |t|
      t.string :token
      t.references :users
      t.datetime :expires_at

      t.timestamps
    end
  end
end
