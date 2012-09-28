class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :json_500
    rescue_from ActiveRecord::RecordNotFound, :with => :json_404
    rescue_from ActionController::RoutingError, :with => :json_404
    rescue_from ActionController::UnknownController, :with => :json_404
    rescue_from ActionController::UnknownAction, :with => :json_404
  end

  def json_500(exception)
    render json: { success: false, message: "Internal server error: #{exception.message}" }, status: 500
  end

  def json_404
    render json: { success:false, message: "Page not found" }, status: 404
  end
end
