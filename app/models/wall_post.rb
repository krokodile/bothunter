class WallPost < ActiveRecord::Base
  belongs_to :person

  has_one :person, as: :author
end
