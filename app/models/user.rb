class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  has_one :profile, dependent: :destroy, inverse_of: :user, autosave: true

  before_validation :normalize_email

  validates :email, uniqueness: { case_sensitive: false }
  validates :profile, presence: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
