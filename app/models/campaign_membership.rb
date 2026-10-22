class CampaignMembership < ApplicationRecord
  belongs_to :campaign, inverse_of: :campaign_memberships
  belongs_to :profile, inverse_of: :campaign_memberships

  validates :profile_id, uniqueness: { scope: :campaign_id }
  validates :campaign_name_key, presence: true, if: :is_dm?
  validates :campaign_name_key, absence: true, unless: :is_dm?
  validates :campaign_name_key,
            uniqueness: { scope: :profile_id, conditions: -> { where(is_dm: true) } },
            if: :is_dm?

  before_validation :set_campaign_name_key

  private

  def set_campaign_name_key
    self.campaign_name_key = is_dm? ? campaign&.comparison_key : nil
  end
end
