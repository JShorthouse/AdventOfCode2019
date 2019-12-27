require "test/unit"
require "./day21_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_find_nodes
    assert_equal 23, find_length_to_exit(map)
  end
end

