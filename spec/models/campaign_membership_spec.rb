require "rails_helper"

RSpec.describe CampaignMembership, type: :model do
  def create_profile(email: "player@example.com")
    User.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
      user.save!
    end.profile
  end

  def create_campaign(name: "The Bards' Rest")
    Campaign.create!(name:)
  end

  it "derives a Unicode case-folded key for DM memberships" do
    membership = described_class.create!(campaign: create_campaign(name: "Straße"), profile: create_profile, is_dm: true)

    expect(membership.campaign_name_key).to eq("strasse")
  end

  it "allows a profile to have one DM membership for each distinct folded name" do
    profile = create_profile
    described_class.create!(campaign: create_campaign(name: "Straße"), profile:, is_dm: true)

    duplicate = described_class.new(campaign: create_campaign(name: "STRASSE"), profile:, is_dm: true)

    expect(duplicate).not_to be_valid
  end

  it "allows equal folded DM names for different profiles and null keys for non-DM memberships" do
    described_class.create!(campaign: create_campaign(name: "The Bards' Rest"), profile: create_profile, is_dm: true)
    described_class.create!(campaign: create_campaign(name: "THE BARDS' REST"), profile: create_profile(email: "other@example.com"), is_dm: true)
    non_dm = described_class.create!(campaign: create_campaign(name: "The Bards' Rest"), profile: create_profile(email: "non-dm@example.com"))

    expect(non_dm.campaign_name_key).to be_nil
  end

  it "enforces foreign keys, membership uniqueness, DM keys, and the partial unique index in the database" do
    campaign = create_campaign
    profile = create_profile
    connection = described_class.connection
    now = connection.quote(Time.current)

    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, created_at, updated_at) VALUES (999999, #{profile.id}, FALSE, #{now}, #{now})")
    end.to raise_error(ActiveRecord::InvalidForeignKey)

    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, created_at, updated_at) VALUES (#{campaign.id}, NULL, FALSE, #{now}, #{now})")
    end.to raise_error(ActiveRecord::NotNullViolation)

    described_class.create!(campaign:, profile:)
    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, created_at, updated_at) VALUES (#{campaign.id}, #{profile.id}, FALSE, #{now}, #{now})")
    end.to raise_error(ActiveRecord::RecordNotUnique)

    second_campaign = create_campaign(name: "Second Campaign")
    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, created_at, updated_at) VALUES (#{second_campaign.id}, #{profile.id}, TRUE, #{now}, #{now})")
    end.to raise_error(ActiveRecord::StatementInvalid)

    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, campaign_name_key, created_at, updated_at) VALUES (#{second_campaign.id}, #{profile.id}, FALSE, 'not-allowed', #{now}, #{now})")
    end.to raise_error(ActiveRecord::StatementInvalid)

    described_class.create!(campaign: second_campaign, profile:, is_dm: true)
    third_campaign = create_campaign(name: "Third Campaign")
    expect do
      connection.execute("INSERT INTO campaign_memberships (campaign_id, profile_id, is_dm, campaign_name_key, created_at, updated_at) VALUES (#{third_campaign.id}, #{profile.id}, TRUE, #{connection.quote(second_campaign.comparison_key)}, #{now}, #{now})")
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
