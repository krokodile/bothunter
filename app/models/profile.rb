class Profile
  include Mongoid::Document

  field :uid
  field :state, default: "pending"


  validates_presence_of :uid  
  belongs_to :group
  
end
