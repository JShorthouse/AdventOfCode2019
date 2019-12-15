require "test/unit"
require "./day15_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_turn_functions
    assert_equal :left, turn_left(:up)
    assert_equal :right, turn_right(:up)
    assert_equal :down, turn_right(:right)
    assert_equal :down, turn_left(:left)
    assert_equal :left, turn_right(:down)
    assert_equal :right, turn_left(:down)
    assert_equal :up, turn_right(:left)
  end

  def test_combine_dirs_functions
    assert_equal :up, combine_dirs(:up, :up)
    assert_equal :right, combine_dirs(:up, :right)
    assert_equal :down, combine_dirs(:up, :down)
    assert_equal :left, combine_dirs(:up, :left)

    assert_equal :up, combine_dirs(:down, :down)
    assert_equal :left, combine_dirs(:right, :down)
    assert_equal :down, combine_dirs(:down, :up)
    assert_equal :left, combine_dirs(:right, :down)

    assert_equal :up, combine_dirs(:right, :left)
    assert_equal :down, combine_dirs(:right, :right)
    assert_equal :down, combine_dirs(:left, :left)
  end
end

