require "rack/test"
require "test-unit"
require "bloc_works"

class BlocWorksTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application.new
  end

  def test_call
    get "/"
    assert last_response.ok?
    assert last_response.has_header?('Content-Type')
    assert !last_response.empty?
  end

end
