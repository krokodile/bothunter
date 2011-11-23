class Group
  include Mongoid::Document
  
  field :link
  field :name
  
  validates_presence_of :link
  
  has_many :profiles
  belongs_to :user
  
end
