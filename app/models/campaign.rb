class Campaign < ActiveRecord::Base
  
  #field :name
  #field :price, default: "0"
  #field :state, default: "pending"
  
  validates_presence_of :name
  
  has_one :group
end
