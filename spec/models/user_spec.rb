require "rails_helper"

RSpec.describe User, type: :model do
  def build_user(email: "sam@example.com")
    described_class.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
    end
  end

  it "normalizes email addresses and gives profiles the normalized email as a display name" do
    user = build_user(email: " SAM@FOO.com ")

    expect(user).to be_valid
    expect(user.save).to be(true)
    expect(user.email).to eq("sam@foo.com")
    expect(user.profile.display_name).to eq("sam@foo.com")
  end

  it "requires an associated profile" do
    user = described_class.new(email: "sam@example.com", password: "password", password_confirmation: "password")

    expect(user).not_to be_valid
    expect(user.errors[:profile]).to include("can't be blank")
  end

  it "rejects case-insensitive duplicate emails" do
    build_user(email: "sam@example.com").save!

    duplicate = build_user(email: " SAM@EXAMPLE.COM ")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include("has already been taken")
  end

  it "enforces case-insensitive email uniqueness in the database" do
    build_user(email: "sam@example.com").save!

    expect do
      described_class.connection.execute <<~SQL.squish
        INSERT INTO users (email, encrypted_password, created_at, updated_at)
        VALUES ('SAM@EXAMPLE.COM', 'not-a-real-password', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      SQL
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
