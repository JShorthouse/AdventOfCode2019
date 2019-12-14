require "test/unit"
require "./day6_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_depth_counting
    # In order
    input = [ ["COM","B"],
              ["B", "C"],
              ["C", "D"],
              ["D", "E"],
              ["E", "F"],
              ["B", "G"],
              ["G", "H"],
              ["D", "I"],
              ["E", "J"],
              ["J", "K"],
              ["K", "L"]]
    planets = create_planets(input)
    print_planets
    assert_equal 42, get_total_depth

    # Out of order
    input = [ ["B", "C"],
              ["C", "D"],
              ["K", "L"],
              ["G", "H"],
              ["D", "E"],
              ["E", "F"],
              ["B", "G"],
              ["COM","B"],
              ["D", "I"],
              ["E", "J"],
              ["J", "K"]]
    planets = create_planets(input)
    print_planets
    assert_equal 42, get_total_depth
  end

  def test_find_join_steps
    input = [ ["COM", "B"],
              ["B","C"],
              ["C","D"],
              ["D","E"],
              ["E","F"],
              ["B","G"],
              ["G","H"],
              ["D","I"],
              ["E","J"],
              ["J","K"],
              ["K","L"],
              ["K","YOU"],
              ["I","SAN"] ]
    planets = create_planets(input)
    assert_equal 4, find_join_steps("YOU", "SAN")
  end
end

