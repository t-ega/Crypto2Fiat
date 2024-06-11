class User < ApplicationRecord
  has_secure_password
  validates_presence_of :email

  has_many :authentication_tokens
end
