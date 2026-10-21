require "rails_helper"

RSpec.describe "Registration", type: :request do
  let(:valid_attributes) do
    { user: { email: " SAM@FOO.com ", password: "password", password_confirmation: "password" } }
  end

  it "creates a user and profile together" do
    expect { post user_registration_path, params: valid_attributes }.to change(User, :count).by(1).and change(Profile, :count).by(1)

    expect(response).to redirect_to(root_path)
    expect(User.last).to have_attributes(email: "sam@foo.com")
    expect(User.last.profile).to have_attributes(display_name: "sam@foo.com")
  end

  it "does not persist either record when registration is invalid" do
    invalid_attributes = valid_attributes.deep_merge(user: { email: "not-an-email", password_confirmation: "different" })

    user_count = User.count
    profile_count = Profile.count
    post user_registration_path, params: invalid_attributes

    expect(User.count).to eq(user_count)
    expect(Profile.count).to eq(profile_count)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rolls back user creation when profile persistence fails" do
    allow_any_instance_of(Profile).to receive(:save).and_return(false)

    user_count = User.count
    profile_count = Profile.count
    post user_registration_path, params: valid_attributes

    expect(User.count).to eq(user_count)
    expect(Profile.count).to eq(profile_count)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "does not expose account editing or deletion routes" do
    get "/users/edit"

    expect(response).to have_http_status(:not_found)
  end
end
