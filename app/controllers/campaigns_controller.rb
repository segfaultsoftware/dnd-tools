class CampaignsController < ApplicationController
  before_action :store_creation_return_path, only: :create, unless: :user_signed_in?
  before_action :authenticate_user!

  def index
    @campaigns = current_user.profile.campaign_catalog
  end

  def new
    @campaign = Campaign.new
  end

  def create
    submitted_name = campaign_params[:name]
    result = Campaigns::Create.call(profile: current_user.profile, name: submitted_name)

    if result.success?
      redirect_to campaigns_path, notice: "Campaign created successfully"
    else
      @campaign = result.campaign
      @campaign.name = submitted_name
      render :new, status: :unprocessable_content
    end
  end

  private

  def store_creation_return_path
    store_location_for(:user, new_campaign_path)
  end

  def campaign_params
    params.expect(campaign: [ :name ])
  end
end
