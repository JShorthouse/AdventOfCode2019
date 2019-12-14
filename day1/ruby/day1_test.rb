require "test/unit"
require "./day1_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_simple_calc
    assert_equal calc_fuel(12), 2
    assert_equal calc_fuel(14), 2
    assert_equal calc_fuel(1969), 654
    assert_equal calc_fuel(100756), 33583
  end

  def test_recursive_calc
    assert_equal recursive_fuel(14), 2
    assert_equal recursive_fuel(1969), 966
    assert_equal recursive_fuel(100756), 50346
  end
end

