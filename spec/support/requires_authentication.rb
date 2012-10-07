# Actions is a hash of http verb to controller action/params. e.g. { get: [:index, {}] }
shared_examples_for "requires authentication" do |actions|
  actions.each do |verb, (action, params)|
    it "should rerequire authentication for #{action}" do
      send(verb, action, params)
      response.status.should == 401
      json = JSON.parse(response.body)
      json['success'].should == false
      json['message'].should == "You must authenticate to access this content"
    end
  end
end