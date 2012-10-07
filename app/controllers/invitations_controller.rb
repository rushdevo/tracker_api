class InvitationsController < BaseApiController
  def index
    render json: {
      success: true,
      invited_by: Invitation.pending.invited_by(current_user).map(&:simple_json),
      invited: Invitation.pending.invited(current_user).map(&:simple_json)
    }
  end

  def new
    json = if params[:email_or_login].present? && (users = User.by_email_or_login(params[:email_or_login].strip).limit(10)).present?
      { success: true, users: users.map(&:simple_json) }
    else
      { success: false, message: "No users matched the given email or login" }
    end
    render json: json
  end

  def create
    invitation = Invitation.new(params[:invitation])
    if !user_can_invite?(invitation)
      render json: { success: false, message: "You do not have permissions to create an invitation for this user" }, status: 401
    elsif invitation.save
      render json: { success: true, message: "Invitation sent to #{invitation.invitee_display_name}" }
    else
      render json: unsuccessful_ar_json(invitation)
    end
  end

  def update
    invitation = Invitation.find(params[:id])
    json = if !user_can_accept?(invitation)
      render json: { success: false, message: "You do not have permissions to accept or reject this invitation" }, status: 401
    elsif invitation.update_attributes(params[:invitation])
      render json: { success: true, message: invitation.status_message }
    else
      render json: unsuccessful_ar_json(invitation)
    end
  end

protected
  def user_can_invite?(invitation)
    invitation.user == current_user
  end

  def user_can_accept?(invitation)
    invitation.invitee == current_user
  end
end
