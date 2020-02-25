require 'test/unit'
require_relative '../fileforstudyci.rb'
include Test::Unit::Assertions

if caller.length == 0
  assert_equal(foo(), "Hello!")
end



