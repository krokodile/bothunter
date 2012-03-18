class CreateOauthTokens < ActiveRecord::Migration
  def up
    create_table :oauth_tokens do |t|
      t.references :user

      t.string :token
      t.string :provider
      t.string :domain

      t.timestamps
    end
  end

  def down
    drop_table :oauth_tokens
  end
end
