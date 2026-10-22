class HomeController < ApplicationController
  def index
    @changelog = changelog_content
  end
end
