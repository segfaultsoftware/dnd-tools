class ApplicationController < ActionController::Base
  include SafeReturnDestination

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def changelog_content
    Rails.root.join("CHANGELOG.md").read
  end
end
