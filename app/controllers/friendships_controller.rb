class FriendshipsController < BaseApiController
  def index
    friendships = Friendship.for_user(current_user)
    render json: {
      success: true,
      friendships: friendships.map(&:simple_json)
    }
  end

  def destroy
    friendship = Friendship.find(params[:id])
    if !friendship.can_modify?(current_user)
      render json: { success: false, message: "You do not have permissions to unfriend this person" }, status: 401
    else
      friendship.destroy
      other = friendship.user == current_user ? friendship.friend : friendship.user
      render json: { success: true, message: "You are no longer friends with #{other.full_name}"}
    end
  end
end
