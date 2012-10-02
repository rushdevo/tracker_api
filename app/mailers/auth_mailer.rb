class AuthMailer < Devise::Mailer
  DO_NOT_REPLY = "do-not-reply@rushdevo.com"

  default from: DO_NOT_REPLY

  def reset_password_instructions(user)
    @resource = user
    mail(:to => @resource.email, :subject => "Tracker: Reset password instructions")
  end
end
