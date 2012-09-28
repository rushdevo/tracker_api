class JsonFailureApp < Devise::FailureApp
  def respond
    self.content_type = 'application/json'
    self.status = 401
    self.response_body = { :success => false, :message => "You must authenticate to access this content" }.to_json
  end
end