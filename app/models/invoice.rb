class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :paid, :type => Boolean, :default => false
  attr_protected :paid

  field :money_amount, :type => Integer, :default => 0 # amount is in cents!

  field :objects_amount, :type => Integer, :default => 0
  #field :objects_filter, :type => String
  #validates_presence_of :objects_filter

#<<<<<<< HEAD
#  referenced_in :profile
#=======
  referenced_in :user

  def money_amount
    super.zero? ? nil : super.cost
  end

  def money_amount= string
    write_attribute :money_amount, Fixnum.cents(string)
  end
#>>>>>>> 4bb417d1f2e88630edfc234f427eb01dea6a4354
end
