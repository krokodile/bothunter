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

         field :approved, type: Boolean, default: false
         index :approved
       
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

  # devise h4xz

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)

    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end

    recoverable
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : :not_approved
  end

end
