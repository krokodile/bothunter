class Promocode
  include Mongoid::Document

  before_create :multiply

  field :groups_limit, type: Integer, default: 0
  field :people_limit, type: Integer, default: 0

  attr_writer :promocodes_count

  has_one :user

protected
  def multiply
    count = @promocodes_count.to_i
    
    if count > 1
      count = count.pred

      attrs = self.attributes
      attrs.delete :_id
      attrs.delete '_id'
      attrs.delete :id
      attrs.delete 'id'

      count.times{ Promocode.create attrs }
    end
  end
end
