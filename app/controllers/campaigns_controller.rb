class CampaignsController < ApplicationController
  before_action :authenticate_user!

  def index
    @campaigns = current_user.profile.campaign_catalog
  end
end
