class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  before_validation :default_display_name, on: :create

  validates :display_name, presence: true

  private

  def default_display_name
    self.display_name ||= user.email.to_s.strip.downcase
  end
end
