class Campaign < ApplicationRecord
  has_many :campaign_memberships, dependent: :destroy, inverse_of: :campaign
  has_many :profiles, through: :campaign_memberships

  before_validation :normalize_name

  validates :name, presence: true
  validate :name_contains_printable_unicode_graphemes

  # A future campaign rename must update this display name and every DM
  # membership's campaign_name_key atomically.
  def comparison_key
    name.to_s.downcase(:fold)
  end

  private

  def normalize_name
    unnormalized_name = name.to_s
    @contains_disallowed_codepoint = unnormalized_name.match?(/[\p{Cc}\p{Zl}\p{Zp}]/)
    self.name = unnormalized_name.strip.unicode_normalize(:nfc)
  end

  def name_contains_printable_unicode_graphemes
    return if name.blank?

    if @contains_disallowed_codepoint || name.match?(/[\p{Cc}\p{Zl}\p{Zp}]/)
      errors.add(:name, "must not contain control characters or line breaks")
    end

    grapheme_count = name.scan(/\X/).length
    return if grapheme_count.between?(3, 128)

    errors.add(:name, "must contain between 3 and 128 characters")
  end
end
