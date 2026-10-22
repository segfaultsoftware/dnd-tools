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

  it "returns to a chosen internal page after sign-in" do
    post user_session_path, params: { user: { email: user.email, password: "password" }, return_to: "/campaigns?view=mine" }

    expect(response).to redirect_to("/campaigns?view=mine")
  end

  it "returns to a protected destination stored by Devise" do
    stub_const("CampaignsController", Class.new(ApplicationController) do
      before_action :authenticate_user!

      def index
        head :ok
      end
    end)

    with_routing do |routes|
      routes.draw do
        devise_for :users, skip: :registrations, controllers: { sessions: "sessions" }
        get "campaigns", to: "campaigns#index"
        root "home#index"
      end

      get "/campaigns"
      expect(response).to redirect_to(new_user_session_path)

      post user_session_path, params: { user: { email: user.email, password: "password" } }
      expect(response).to redirect_to("/campaigns")
    end
  end

  it "keeps a chosen destination after failed sign-in" do
    post user_session_path, params: { user: { email: user.email, password: "wrong-password" }, return_to: "/campaigns" }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('name="return_to"')
    expect(response.body).to include('value="/campaigns"')
  end

  [ "https://evil.example.com/campaigns", "//evil.example.com/campaigns", "http://evil.example.com", "http://[" ].each do |return_to|
    it "falls back to the landing page for an unsafe return destination: #{return_to.inspect}" do
      post user_session_path, params: { user: { email: user.email, password: "password" }, return_to: return_to }

      expect(response).to redirect_to(root_path)
    end
  end

  it "accepts a same-origin absolute return destination" do
    post user_session_path, params: { user: { email: user.email, password: "password" }, return_to: "http://www.example.com/campaigns" }

    expect(response).to redirect_to("/campaigns")
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
