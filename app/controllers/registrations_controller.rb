class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
    resource.build_profile

    resource.save
    yield resource if block_given?

    if resource.persisted?
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      resource.errors.add(:base, "Profile could not be created.") if resource.errors.empty?
      render :new, status: :unprocessable_entity
    end
  end

  protected

  def after_sign_up_path_for(_resource)
    root_path
  end
end
