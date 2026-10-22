require "rails_helper"

RSpec.describe Campaign, type: :model do
  def create_profile(email: "player@example.com")
    User.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
      user.save!
    end.profile
  end

  it "normalizes names to trimmed NFC while retaining display spelling and internal whitespace" do
    campaign = described_class.create!(name: "  Cafe\u0301  del   Mar  ")

    expect(campaign.name).to eq("Café  del   Mar")
  end

  it "allows printable Unicode names" do
    [ "  D&D: O'Brien's Quest!  ", "冒険者たちの旅", "⚔️  Dragon's  Den  ⚔️" ].each do |name|
      expect(described_class.new(name:)).to be_valid
    end
  end

  it "measures the name length in grapheme clusters" do
    expect(described_class.new(name: "👩‍👩‍👧‍👦" * 3)).to be_valid
    expect(described_class.new(name: "é" * 129)).not_to be_valid
    expect(described_class.new(name: "👩‍👩‍👧‍👦" * 2)).not_to be_valid
  end

  it "rejects control characters and line breaks" do
    [ "A\nBC", "A\rBC", "A\tBC", "A\u0000BC", "\nABC" ].each do |name|
      expect(described_class.new(name:)).not_to be_valid
    end
  end

  it "traverses campaign memberships from a profile" do
    profile = create_profile
    campaign = described_class.create!(name: "The Bards' Rest")
    CampaignMembership.create!(campaign:, profile:)
    dm_campaign = described_class.create!(name: "The Guild Hall")
    CampaignMembership.create!(campaign: dm_campaign, profile:, is_dm: true)

    expect(profile.campaigns).to contain_exactly(campaign, dm_campaign)
    expect(profile.dm_campaigns).to contain_exactly(dm_campaign)
  end

  it "orders a profile's catalog by Unicode case-folded name and display spelling" do
    profile = create_profile
    campaigns = [ "⚔️ Quest", "Éclair", "apple", "Álpha", "straße", "STRASSE" ].map do |name|
      described_class.create!(name:).tap { |campaign| CampaignMembership.create!(campaign:, profile:) }
    end

    expect(profile.campaign_catalog.map(&:name)).to eq([ "apple", "STRASSE", "straße", "Álpha", "Éclair", "⚔️ Quest" ])
    expect(profile.campaign_catalog).to match_array(campaigns)
  end
end
