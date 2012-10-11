require 'api_controller_helpers'

class UsersController < Devise::RegistrationsController
  include ApiControllerHelpers

  def create
    build_resource

    if resource.save
      render json: successful_json_with_user_information(resource).merge(message: "You have successfully created an account for #{resource.login}")
    else
      render json: unsuccessful_ar_json(resource)
    end
  end

  def update
    resource = User.to_adapter.get!(current_user.to_key)

    if resource.update_attributes(resource_params)
      render json: successful_json_with_user_information(resource).merge(message: "You have successfully updated the account for #{resource.login}")
    else
      render json: unsuccessful_ar_json(resource)
    end
  end

  # Make sure all the additional stuff from the Devise controller 404s
  def new
    json_404
  end

  def edit
    json_404
  end

  def index
    json_404
  end

  def destroy
    json_404
  end

  def cancel
    json_404
  end

end
