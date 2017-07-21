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

  def test_map
    # map "books/:id/show", "BooksController::show"
    # My Book - id 4

    get "/books/2/show"
    assert_equal <<-TESTHTML, last_response.body
    <div>
      <h2>Practical Object-Oriented Design in Ruby</h2>
      <h3>Sandi Metz</h3><br>

      <div>
        <a href="/books/destroy?id=2"> Delete Practical Object-Oriented Design in Ruby</a>
      </div>

      <div>
        <a href="/books/edit?id=2 Edit Practical Object-Oriented Design in Ruby </a>
      </div>
    </div>
    TESTHTML
  end

  def test_look_up
    get "/books/1/show"
    assert_equal <<-TESTHTML, last_response.body
    <div>
      <h2>The Well-Grounded Rubyist</h2>
      <h3>David A. Black</h3><br>

      <div>
        <a href="/books/destroy?id=1"> Delete The Well-Grounded Rubyist</a>
      </div>

      <div>
        <a href="/books/edit?id=1"> Edit The Well-Grounded Rubyist</a>
      </div>
    </div>
    TESTHTML
  end
end
