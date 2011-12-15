class Group
  include Mongoid::Document
  
  field :link, type:String
  field :name, type:String
  field :gid,  type:String
  field :domain, type:String
  field :title, type:String
  validates_presence_of :gid
  
  has_and_belongs_to_many :persons
  has_and_belongs_to_many :users
end
