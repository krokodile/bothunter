class Promocode < ActiveRecord::Base
  attr_accessor :email_to

  belongs_to :user

  validates_numericality_of :groups_limit, greater_than: 0
  validates_numericality_of :people_limit, greater_than: 0
  validates_email_format_of :email_to, :if => proc { |record| record.email_to.present? }
  validates :code, uniqueness: true, presence: true

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
