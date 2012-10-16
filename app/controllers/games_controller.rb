class GamesController < BaseApiController
  def index
    render json: {
      success: true,
      games: Game.incomplete.for_user(current_user).map(&:simple_json)
    }
  end

  def create
    game = Game.new(params[:game])
    game.owner = current_user

    json = if game.save
      { success: true, game: game.simple_json }
    else
      unsuccessful_ar_json(game)
    end
    render json: json
  end

  def update
    game = Game.find(params[:id])
    if game.validate_params_for(current_user, params[:game])
      if game.update_attributes(params[:game])
        render json: { success: true, game: game.simple_json }
      else
        render json: unsuccessful_ar_json(game)
      end
    else
      render json: { success: false, message: "You do not have permissions to modify this game" }, status: 401
    end
  end
end
