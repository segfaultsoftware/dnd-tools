require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) do
    User.new(email: "sam@example.com", password: "password", password_confirmation: "password").tap do |created_user|
      created_user.build_profile
      created_user.save!
    end
  end

  it "signs in with valid credentials and creates a session" do
    post user_session_path, params: { user: { email: " SAM@EXAMPLE.COM ", password: "password" } }

    expect(response).to redirect_to(root_path)
    expect(session["warden.user.user.key"]).to be_present
  end

  it "renders an accessible authentication error for invalid credentials" do
    post user_session_path, params: { user: { email: user.email, password: "wrong-password" } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('role="alert"')
    expect(response.body).to include("Unable to sign in")
  end

  it "sets a three-week remembered-session cookie when requested" do
    post user_session_path, params: { user: { email: user.email, password: "password", remember_me: "1" } }

    expect(response.cookies["remember_user_token"]).to be_present
    expect(user.reload.remember_created_at).to be_present
  end

  it "forgets this browser without invalidating remembered sessions elsewhere" do
    post user_session_path, params: { user: { email: user.email, password: "password", remember_me: "1" } }
    remembered_at = user.reload.remember_created_at

    delete destroy_user_session_path

    expect(response).to redirect_to(root_path)
    expect(session["warden.user.user.key"]).to be_nil
    expect(user.reload.remember_created_at).to eq(remembered_at)
  end

  it "does not expose deferred account-management routes" do
    get "/users/password/new"

    expect(response).to have_http_status(:not_found)
  end
end
