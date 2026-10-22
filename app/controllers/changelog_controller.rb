class ChangelogController < ApplicationController
  def show
    @changelog = changelog_content
  end
end
