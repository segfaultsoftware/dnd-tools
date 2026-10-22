class SessionsController < Devise::SessionsController
  include SafeReturnDestination

  def create
    @stored_return_destination = safe_return_destination(session["#{resource_name}_return_to"])
    super
  end

  protected

  def after_sign_in_path_for(_resource)
    after_authentication_path
  end
end
