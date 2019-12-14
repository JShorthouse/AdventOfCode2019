require "test/unit"
require "./day12_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_moon_simulation
    m1 = [
      Moon.new(-8, -10,   0),
      Moon.new(5,    5,  10),
      Moon.new(2,   -7,   3),
      Moon.new(9,   -8,  -3)
    ]
    run_simulation(m1, 100)
    
    assert_equal 1940, calc_total_energy(m1)

    m2 = [
      Moon.new(-1,   0,   2),
      Moon.new( 2, -10,  -7),
      Moon.new( 4,  -8,   8),
      Moon.new( 3,   5,  -1)
    ]
    assert_equal 2772, find_repeated_step(m2)


    m3 = [
      Moon.new(-8, -10,   0),
      Moon.new(5,    5,  10),
      Moon.new(2,   -7,   3),
      Moon.new(9,   -8,  -3)
    ]
    assert_equal 4686774924, find_repeated_step(m3)
  end
end
