# encoding: utf-8

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :company, :full_name, :phone_number, :message, :promocode_value

  after_create do
    if @promocode_value.present? && self.promocode.present?
      self.promocode.touch
    end
  end

  belongs_to :invoices

  has_one :promocode
  has_many :campaigns
  has_many :oauth_tokens, uniq: true
  has_and_belongs_to_many :groups, uniq: true

  validates_presence_of :full_name, :company, :phone_number
  validate :promocode_value_check
         
  def update_with_password params = {}
    params.delete :current_password
    self.update_without_password params
  end

  def promocode_value_check
    if !self.approved? && self.new_record? && !@promocode_value.nil?
      if self.promocode.nil?
        errors.add(:promocode_value, 'неправильный промокод')
      else
        self.approved       = true
        self.objects_amount = self.promocode.groups_limit
        self.people_limit   = self.promocode.people_limit
      end
    end
  end

  def admin?
    self.rights.to_s == 'admin'
  end

  def manager?
    self.rights.to_s == 'manager'
  end

  def promocode_value
    self.promocode.try(:code).presence || @promocode_value
  end

  def promocode_value= code
    @promocode_value = code

    if !self.approved? && promo_code = Promocode.find_by_code_and_user_id(code, nil)
      self.promocode = promo_code
    end
  end

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

  def token_for provider
    self.oauth_tokens.find_by_provider(provider).token rescue nil
  end
end
