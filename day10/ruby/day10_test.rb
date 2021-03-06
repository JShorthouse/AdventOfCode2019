require "test/unit"
require "./day10_lib.rb"


class LibTests < Test::Unit::TestCase

  def test_best_asteroid
    asteroids = array_to_objects([
      [".","#",".",".","#"],
      [".",".",".",".","."],
      ["#","#","#","#","#"],
      [".",".",".",".","#"],
      [".",".",".","#","#"]
    ])

    calculate_asteroid_visibility(asteroids)

    asteroids.each do |ast|
      puts "(#{ast.x}, #{ast.y}) => #{ast.visible_list.count}"
    end

    ast = get_best_asteroid(asteroids)
    assert_equal [3,4], [ast.x, ast.y]
    assert_equal 8, ast.visible_count

    
    asteroids = array_to_objects([
      [".",".",".",".",".",".","#",".","#","."],
      ["#",".",".","#",".","#",".",".",".","."],
      [".",".","#","#","#","#","#","#","#","."],
      [".","#",".","#",".","#","#","#",".","."],
      [".","#",".",".","#",".",".",".",".","."],
      [".",".","#",".",".",".",".","#",".","#"],
      ["#",".",".","#",".",".",".",".","#","."],
      [".","#","#",".","#",".",".","#","#","#"],
      ["#","#",".",".",".","#",".",".","#","."],
      [".","#",".",".",".",".","#","#","#","#"]
    ])
    calculate_asteroid_visibility(asteroids)
    ast = get_best_asteroid(asteroids)
    assert_equal [5,8], [ast.x, ast.y]
    assert_equal 33, ast.visible_count

    asteroids = array_to_objects([
      ["#",".","#",".",".",".","#",".","#","."],
      [".","#","#","#",".",".",".",".","#","."],
      [".","#",".",".",".",".","#",".",".","."],
      ["#","#",".","#",".","#",".","#",".","#"],
      [".",".",".",".","#",".","#",".","#","."],
      [".","#","#",".",".","#","#","#",".","#"],
      [".",".","#",".",".",".","#","#",".","."],
      [".",".","#","#",".",".",".",".","#","#"],
      [".",".",".",".",".",".","#",".",".","."],
      [".","#","#","#","#",".","#","#","#","."]
    ])
    calculate_asteroid_visibility(asteroids)
    ast = get_best_asteroid(asteroids)
    assert_equal [1,2], [ast.x, ast.y]
    assert_equal 35, ast.visible_count
  
    asteroids = array_to_objects([
      [".","#",".",".","#",".",".","#","#","#"],
      ["#","#","#","#",".","#","#","#",".","#"],
      [".",".",".",".","#","#","#",".","#","."],
      [".",".","#","#","#",".","#","#",".","#"],
      ["#","#",".","#","#",".","#",".","#","."],
      [".",".",".",".","#","#","#",".",".","#"],
      [".",".","#",".","#",".",".","#",".","#"],
      ["#",".",".","#",".","#",".","#","#","#"],
      [".","#","#",".",".",".","#","#",".","#"],
      [".",".",".",".",".","#",".","#",".","."]
    ])
    calculate_asteroid_visibility(asteroids)
    ast = get_best_asteroid(asteroids)
    assert_equal [6,3], [ast.x, ast.y]
    assert_equal 41, ast.visible_count
  
    asteroids = array_to_objects([
      [".","#",".",".","#","#",".","#","#","#",".",".",".","#","#","#","#","#","#","#"],
      ["#","#",".","#","#","#","#","#","#","#","#","#","#","#","#",".",".","#","#","."],
      [".","#",".","#","#","#","#","#","#",".","#","#","#","#","#","#","#","#",".","#"],
      [".","#","#","#",".","#","#","#","#","#","#","#",".","#","#","#","#",".","#","."],
      ["#","#","#","#","#",".","#","#",".","#",".","#","#",".","#","#","#",".","#","#"],
      [".",".","#","#","#","#","#",".",".","#",".","#","#","#","#","#","#","#","#","#"],
      ["#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#"],
      ["#",".","#","#","#","#",".",".",".",".","#","#","#",".","#",".","#",".","#","#"],
      ["#","#",".","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#"],
      ["#","#","#","#","#",".","#","#",".","#","#","#",".",".","#","#","#","#",".","."],
      [".",".","#","#","#","#","#","#",".",".","#","#",".","#","#","#","#","#","#","#"],
      ["#","#","#","#",".","#","#",".","#","#","#","#",".",".",".","#","#",".",".","#"],
      [".","#","#","#","#","#",".",".","#",".","#","#","#","#","#","#",".","#","#","#"],
      ["#","#",".",".",".","#",".","#","#","#","#","#","#","#","#","#","#",".",".","."],
      ["#",".","#","#","#","#","#","#","#","#","#","#",".","#","#","#","#","#","#","#"],
      [".","#","#","#","#",".","#",".","#","#","#",".","#","#","#",".","#",".","#","#"],
      [".",".",".",".","#","#",".","#","#",".","#","#","#",".",".","#","#","#","#","#"],
      [".","#",".","#",".","#","#","#","#","#","#","#","#","#","#","#",".","#","#","#"],
      ["#",".","#",".","#",".","#","#","#","#","#",".","#","#","#","#",".","#","#","#"],
      ["#","#","#",".","#","#",".","#","#","#","#",".","#","#",".","#",".",".","#","#"]
    ])
    calculate_asteroid_visibility(asteroids)
    ast = get_best_asteroid(asteroids)
    assert_equal [11,13], [ast.x, ast.y]
    assert_equal 210, ast.visible_count

    vaporised = vaporise_asteroids(asteroids, ast, 200)
    assert_equal [8,2], [vaporised.x, vaporised.y]

  end
end
