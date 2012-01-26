class Group
  include Mongoid::Document
  
  field :link, type: String
  field :name, type: String
  field :gid,  type: String
  field :domain, type: String
  field :title, type: String
  validates_presence_of :gid
  
  has_and_belongs_to_many :persons #, unique: true
  has_and_belongs_to_many :users   #, unique: true
  index :gid, background: true
  index :domain, background: true
end
