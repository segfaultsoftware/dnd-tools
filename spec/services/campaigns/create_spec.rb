require "rails_helper"

RSpec.describe Campaigns::Create do
  def create_profile(email: "player@example.com")
    User.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
      user.save!
    end.profile
  end

  it "creates the campaign and its creator's DM membership together" do
    profile = create_profile

    result = described_class.call(profile:, name: "  Cafe\u0301  del   Mar  ")

    expect(result).to be_success
    expect(result.campaign.name).to eq("Café  del   Mar")
    expect(result.membership).to have_attributes(profile:, is_dm: true, campaign_name_key: "café  del   mar")
    expect(result.campaign.campaign_memberships).to contain_exactly(result.membership)
  end

  it "returns name validation errors without persisting either record" do
    profile = create_profile

    result = described_class.call(profile:, name: "\nAB")

    expect(result).not_to be_success
    expect(result.errors[:name]).to include("must not contain control characters or line breaks")
    expect(Campaign).not_to exist
    expect(CampaignMembership).not_to exist
  end

  it "rolls back the campaign when its initial DM membership cannot be saved" do
    profile = create_profile
    allow_any_instance_of(CampaignMembership).to receive(:save!).and_raise(
      ActiveRecord::RecordInvalid.new(CampaignMembership.new)
    )

    result = described_class.call(profile:, name: "The Bards' Rest")

    expect(result).not_to be_success
    expect(Campaign).not_to exist
    expect(CampaignMembership).not_to exist
  end

  it "returns an inline-renderable duplicate error for equivalent names owned by the same DM" do
    profile = create_profile
    described_class.call(profile:, name: "Straße")

    result = described_class.call(profile:, name: "  STRASSE  ")

    expect(result).not_to be_success
    expect(result.errors[:name]).to include("You already DM a campaign with this name")
    expect(Campaign.count).to eq(1)
    expect(CampaignMembership.count).to eq(1)
  end

  it "turns a database uniqueness collision into duplicate feedback and rolls back the campaign" do
    profile = create_profile
    allow_any_instance_of(CampaignMembership).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique)

    result = described_class.call(profile:, name: "The Bards' Rest")

    expect(result).not_to be_success
    expect(result.errors[:name]).to include("You already DM a campaign with this name")
    expect(Campaign).not_to exist
    expect(CampaignMembership).not_to exist
  end

  it "allows different profiles to DM campaigns with equivalent names" do
    first_profile = create_profile
    second_profile = create_profile(email: "other@example.com")

    first_result = described_class.call(profile: first_profile, name: "Straße")
    second_result = described_class.call(profile: second_profile, name: "STRASSE")

    expect(first_result).to be_success
    expect(second_result).to be_success
    expect(Campaign.count).to eq(2)
    expect(CampaignMembership.count).to eq(2)
  end
end
