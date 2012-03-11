class Promocode
  include Mongoid::Document

  #before_create :multiply

  field :groups_limit, type: Integer, default: 0
  field :people_limit, type: Integer, default: 0

  #attr_accessor :promocodes_count # reader needed for form generation

  references_one :user

  field :code, type: String, default: nil
  index :code, unique: true

#protected
#  def multiply
#    count = @promocodes_count.to_i
#    
#    if count > 1
#      count = count.pred
#
#      attrs = self.attributes
#      attrs.delete :_id
#      attrs.delete '_id'
#      attrs.delete :id
#      attrs.delete 'id'
#
#      count.times{ Promocode.create attrs }
#    end
#  end
end
