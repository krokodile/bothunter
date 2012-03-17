class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :company, :full_name, :phone_number, :message
         
  has_many :campaigns
  has_many :oauth_tokens, uniq: true
  has_and_belongs_to_many :groups, uniq: true

  validates_presence_of :full_name, :company, :phone_number
         
  def update_with_password(params={})
    params.delete(:current_password)
    self.update_without_password(params)
  end

  #references_many :invoices

  #referenced_in :promocode
  #index :promocode_id, unique: true

  #before_create :verify_promocode

  def manager?
    true #kind_of? Manager
  end

  def promocode
    @promocode || Promocode.find(promocode_id).code rescue '' 
  end

  def promocode= code
    @promocode = code
  end

  # devise h4xz

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)

    if !recoverable.approved?
      recoverable.errors[:base] << I18n.t("devise.registrations.signed_up_but_inactive")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end

    recoverable
  end

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ? super : I18n.t("devise.registrations.signed_up_but_inactive")
  end

  protected

  def verify_promocode
    code = @promocode.to_s.strip

    unless code.empty?
      code = Promocode.where(code: code).first rescue nil

      if code and code.user.nil?
        write_attribute :promocode_id, code.id

        write_attribute :objects_amount, code.groups_limit
        write_attribute :people_limit, code.people_limit

        write_attribute :approved, true
      end
    end
  end
end
