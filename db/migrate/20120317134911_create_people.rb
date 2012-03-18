class CreatePeople < ActiveRecord::Migration
  def up
    create_table :people do |t|
      t.datetime :bdate

      t.string :uid, uniq: true
      t.string :domain, uniq: true, null: true
      t.string :first_name
      t.string :last_name
      t.string :state
      t.string :photo

      t.integer :friends_count

      t.timestamps
    end
  end

  def down
    drop_table :people
  end
end
