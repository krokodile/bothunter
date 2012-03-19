class CreateWallPosts < ActiveRecord::Migration
  def up
    create_table :wall_posts do |t|
      t.references :person

      t.boolean :own_post, default: false

      t.string :post_id, null: false
      t.string :src
      t.string :copy_post_id

      t.integer :comments_count
      t.integer :likes_count

      t.datetime :pub_date

      t.text :text
    end
  end

  def down
    drop_table :wall_posts
  end
end
