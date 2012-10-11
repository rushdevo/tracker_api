RSpec::Matchers.define :include_only do |*expected|
  match do |actual|
    actual.length == expected.length && actual.all? { |obj| expected.include?(obj) }
  end
end