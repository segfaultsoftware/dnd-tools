class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  has_many :campaign_memberships, dependent: :destroy, inverse_of: :profile
  has_many :campaigns, through: :campaign_memberships
  has_many :dm_campaign_memberships, -> { where(is_dm: true) }, class_name: "CampaignMembership", inverse_of: :profile
  has_many :dm_campaigns, through: :dm_campaign_memberships, source: :campaign

  before_validation :default_display_name, on: :create

  validates :display_name, presence: true

  private

  def default_display_name
    self.display_name ||= user.email.to_s.strip.downcase
  end
end
