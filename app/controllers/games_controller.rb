class GamesController < ApplicationController
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
    # TODO: This should be used to join the game? Look for param :user_id to set up a new user
  end
end
