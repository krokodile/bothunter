class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.boolean :approved

      t.string :full_name
      t.string :phone_number
      t.string :company
      t.string :message

      t.integer :objects_amount, default: 0
      t.integer :people_limit, default: 100

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
