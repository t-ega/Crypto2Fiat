class AuthenticationToken < ApplicationRecord
  scope :not_expired, -> { where("expires_at > ?", Time.current) }
  belongs_to :user

  validates_presence_of :token

  def self.revoke_token(token)
    token = AuthenticationToken.find_by_token(token)
    token&.update(expires_at: Time.current)
  end

  def self.find_user_from_token(token)
    token = not_expired.find_by_token(token)
    token&.user
  end
end
