class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
         field :full_name
         #field :admin, type: Boolean, default: false
         field :phone_number
         field :company
       
         validates_presence_of :full_name, :company, :phone_number
         
         has_many :campaigns
         has_and_belongs_to_many :groups
         
         def update_with_password(params={})
           params.delete(:current_password)
           self.update_without_password(params)
         end

  field :objects_amount, :type => Integer, :default => 0 # amount is in cents!
  attr_protected :objects_amount
  
  attr_protected :_type

  references_many :invoices

  def manager?
    kind_of? Manager
  end
        
end
