require 'api_controller_helpers'

class BaseApiController < ApplicationController
  include ApiControllerHelpers

  respond_to :json
end