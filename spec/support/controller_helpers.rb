RSpec.configure do |config|
  config.before(:each, type: :controller) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end

def json_from_response(expected_status, expected_success)
  response.status.should == expected_status
  json = JSON.parse(response.body)
  json['success'].should == expected_success
  json
end

def compare_json_to_simple_json(json, object)
  json.with_indifferent_access.should == object.simple_json.with_indifferent_access
end