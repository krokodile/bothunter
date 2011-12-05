class Person
  include Mongoid::Document
  field :uid, type:String
  field :domain, type:String
  field :first_name, type:String
  field :last_name, type:String
  field :state, type:Symbol,  default: :pending
  field :friends_count, type:Integer
  field :photo, type:String
  has_and_belongs_to_many :groups
  #has_many :wall_posts, as: :posted
  has_many :wall_posts
  #validates_presence_of :uid
  validates_presence_of :state
  #validates :state, in: [:pending,:robot,:alive,:unknown]
  scope :by_state,->(state) { where(state:limit) }

end
