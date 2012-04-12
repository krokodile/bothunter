class AddDefaultValuesForPerson < ActiveRecord::Migration
  def change
    change_column :people, :friends_count, :integer, default: 0

    Person.where(friends_count: nil).map { |p| p.update_attributes(friends_count: 0) }
  end
end
