module ApiControllerHelpers
protected
  def unsuccessful_ar_json(object)
    { success: false, message: ar_message_for_json(object) }
  end

  def ar_message_for_json(object)
    "Unable to save #{object.class.name}: " + object.errors.full_messages.join(", ")
  end

  def successful_json_with_user_information(user)
    { success: true, auth_token: user.authentication_token, login: user.login }
  end
end