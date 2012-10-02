class PasswordsController < Devise::PasswordsController
  include ApiControllerHelpers

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      render json: { success: true, email: resource.email, message: "An email has been sent with password reset instructions" }
    else
      render json: { success: false, message: ar_message_for_json(resource) }
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      render json: successful_json_with_user_information(resource).merge(message: "Password reset for #{resource.login}")
    else
      render json: { success: false, message: ar_message_for_json(resource) }
    end
  end

  # Hide the forms under a 404 (API only)
  # TODO: Eventually probably want to implement these so you can reset password from the web too
  def new
    json_404
  end

  def edit
    json_404
  end
end