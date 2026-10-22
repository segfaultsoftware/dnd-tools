require "uri"

module SafeReturnDestination
  extend ActiveSupport::Concern

  included do
    helper_method :authentication_return_path, :return_destination
  end

  private

  def after_authentication_path
    requested_destination = params[:return_to]

    return root_path if requested_destination.present? && safe_return_destination(requested_destination).nil?

    safe_return_destination(requested_destination) ||
      @stored_return_destination ||
      safe_return_destination(stored_location_for(resource_name)) ||
      root_path
  end

  def authentication_return_path
    request.fullpath if request.get? && !devise_controller?
  end

  def return_destination
    safe_return_destination(params[:return_to])
  end

  def safe_return_destination(value)
    return unless value.is_a?(String)

    destination = URI.parse(value)

    if destination.relative?
      return unless destination.host.nil? && destination.userinfo.nil? && destination.port.nil?
      return unless destination.path&.start_with?("/") && !destination.path.start_with?("//")

      request_uri_for(destination)
    elsif same_origin?(destination)
      request_uri_for(destination)
    end
  rescue URI::InvalidURIError
    nil
  end

  def same_origin?(destination)
    destination.userinfo.nil? &&
      destination.scheme == request.protocol.delete_suffix("://") &&
      destination.host == request.host &&
      destination.port == request.port
  end

  def request_uri_for(destination)
    [ destination.path, destination.query.presence ].compact.join("?")
  end
end
