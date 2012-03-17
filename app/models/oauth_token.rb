class OauthToken < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :token, :domain, :provider
  validates_uniqueness_of :domain, scope: [:provider]
end
