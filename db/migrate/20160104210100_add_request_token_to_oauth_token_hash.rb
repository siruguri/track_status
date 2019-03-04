class AddRequestTokenToOauthTokenHash < ActiveRecord::Migration[4.2]
  def change
    add_column :oauth_token_hashes, :request_token, :string
  end
end
