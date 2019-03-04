class CreateOauthTokenHash < ActiveRecord::Migration[4.2]
  def change
    create_table :oauth_token_hashes do |t|
      t.string :source
      t.string :token
      t.string :secret
      t.integer :user_id
      
      t.timestamps
    end
  end
end
