class AuthenticationTokensController < BaseApiController
  skip_before_filter :authenticate_user!, only: :create

  def create
    resource = User.find_for_database_authentication(login: params[:login])

    if resource && resource.valid_password?(params[:password])
      resource.reset_authentication_token
      resource.save(validate: false)
      render :json => successful_json_with_user_information(resource)
    else
      warden.custom_failure!
      render :json => { success: false, message: "Invalid login or password" }, status: 401
    end

  end

  def destroy
    # Clear out the auth token so they have to re-login
    current_user.clear_authentication_token!
    # In case we have any session saved, clear it out
    sign_out(current_user)
    render :json => { success: true }
  end
end
