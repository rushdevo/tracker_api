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
  normalize_hash(json).should == normalize_hash(object.simple_json)
end

def normalize_hash(hash)
  convert_to_json_values(hash).with_indifferent_access
end

def convert_to_json_values(hash)
  hash.keys.each do |key|
    if hash[key].kind_of?(Hash)
      # Recurse if the value at that key is also a hash
      hash[key] = convert_to_json_values(hash[key])
    else
      hash[key] = hash[key].as_json
    end
  end
  hash
end