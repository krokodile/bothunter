class WallPost
  include Mongoid::Document
  field :uid, type:String
  field :src, type:String
  field :text, type:String
  field :comments_count, type:String
  field :likes_count, type:String
  field :pub_date, type:DateTime
  field :repost_from, type:String
  field :own_post, type:Boolean, default: false
  belongs_to :person
  #has_one :person, as= :author
end


class PersonWallPost < WallPost
  belongs_to :person
  #belongs_to :wall_posts
end
