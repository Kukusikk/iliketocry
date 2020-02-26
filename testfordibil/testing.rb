require 'test/unit'
require_relative '../fileforstudyci.rb'
include Test::Unit::Assertions

class HelloTest < Test::Unit::TestCase
  def test_world
    assert_equal(foo(), "Hello!")
  end
end



