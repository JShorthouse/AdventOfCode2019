require "test/unit"
require "./day24_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_simulate_grid
    grid = [
      [".",".",".",".","#"],
      ["#",".",".","#","."],
      ["#",".",".","#","#"],
      [".",".","#",".","."],
      ["#",".",".",".","."]
    ]

    grid = simulate_grid(grid)
    assert_equal [
      ["#",".",".","#","."],
      ["#","#","#","#","."],
      ["#","#","#",".","#"],
      ["#","#",".","#","#"],
      [".","#","#",".","."]
    ], grid


    grid = simulate_grid(grid)
    assert_equal [
      ["#","#","#","#","#"],
      [".",".",".",".","#"],
      [".",".",".",".","#"],
      [".",".",".","#","."],
      ["#",".","#","#","#"]
    ], grid


    grid = simulate_grid(grid)
    assert_equal [
      ["#",".",".",".","."],
      ["#","#","#","#","."],
      [".",".",".","#","#"],
      ["#",".","#","#","."],
      [".","#","#",".","#"]
    ], grid


    grid = simulate_grid(grid)
    assert_equal [
      ["#","#","#","#","."],
      [".",".",".",".","#"],
      ["#","#",".",".","#"],
      [".",".",".",".","."],
      ["#","#",".",".","."]
    ], grid
  end

  def test_grid_checksum
    grid = [
      ["#",".","#",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."]
    ]
    assert_equal 5, get_grid_checksum(grid)

    grid = [
      ["#",".","#",".","."],
      ["#",".",".",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."]
    ]
    assert_equal 37, get_grid_checksum(grid)


    grid = [
      ["#","#","#","#","#"],
      ["#","#","#","#","#"],
      ["#","#","#","#","#"],
      ["#","#","#","#","#"],
      ["#","#","#","#","#"]
    ]
    assert_equal 33554431, get_grid_checksum(grid)


    grid = [
      [".",".",".",".","."],
      [".",".",".",".","."],
      [".",".",".",".","."],
      ["#",".",".",".","."],
      [".","#",".",".","."]
    ]
    assert_equal 2129920, get_grid_checksum(grid)
  end

  def test_recurs_adj
    assert_equal [
      [1, 1, 4],
      [2, 2, 3],
      [2, 1, 2],
      [1, 0, 3]
    ], get_recurs_adjacent(1, 0, 4)

    assert_equal [
      [2, 3, 2],
      [1, 4, 1],
      [1, 3, 0],
      [2, 2, 1]
    ], get_recurs_adjacent(1, 4, 0)

    # right
    assert_equal [
      [1, 3, 3],
      [1, 2, 4],
      [1, 1, 3],
      [0, 0, 4],
      [0, 1, 4],
      [0, 2, 4],
      [0, 3, 4],
      [0, 4, 4],
    ], get_recurs_adjacent(1, 2, 3)

    # down
    assert_equal [
      [0, 0, 0],
      [0, 0, 1],
      [0, 0, 2],
      [0, 0, 3],
      [0, 0, 4],
      [1, 1, 3],
      [1, 0, 2],
      [1, 1, 1],
    ], get_recurs_adjacent(1, 1, 2)

    # left
    assert_equal [
      [1, 3, 1],
      [0, 0, 0],
      [0, 1, 0],
      [0, 2, 0],
      [0, 3, 0],
      [0, 4, 0],
      [1, 1, 1],
      [1, 2, 0],
    ], get_recurs_adjacent(1, 2, 1)

    # up
    assert_equal [
      [1, 4, 2],
      [1, 3, 3],
      [0, 4, 0],
      [0, 4, 1],
      [0, 4, 2],
      [0, 4, 3],
      [0, 4, 4],
      [1, 3, 1],

    ], get_recurs_adjacent(1, 3, 2)

    # same level
    assert_equal [
      [1, 4, 3],
      [1, 3, 4],
      [1, 2, 3],
      [1, 3, 2],

    ], get_recurs_adjacent(1, 3, 3)
  end

  def test_sim_recursive
    grid = [
      [".",".",".",".","#"],
      ["#",".",".","#","."],
      ["#",".","?","#","#"],
      [".",".","#",".","."],
      ["#",".",".",".","."]
    ]
    grids = gen_recursive_grid(grid, 10)

    grids = run_recursive(grids, 10)

    assert_equal 99, count_total_bugs(grids)
  end
end
