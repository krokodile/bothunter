class Promocode < ActiveRecord::Base
  ##before_create :multiply
  #
  #
  ##attr_accessor :promocodes_count # reader needed for form generation

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
