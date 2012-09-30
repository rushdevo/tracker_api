module ApiControllerHelpers
protected
  def ar_message_for_json(object)
    "Unable to save #{object.class.name}: " + object.errors.full_messages.join(", ")
  end

  def successful_json_with_user_information(user)
    { success: true, auth_token: user.authentication_token, login: user.login }
  end
end