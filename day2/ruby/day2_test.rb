require "test/unit"
require "./day2_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_process_command
    arr = [1,0,0,0]
    process_command(arr, 0)
    assert_equal [2,0,0,0], arr

    arr = [2,3,0,3]
    process_command(arr, 0)
    assert_equal [2,3,0,6], arr
  end

  def test_process_program
    arr = [1,0,0,0,99]
    process_program(arr)
    assert_equal [2,0,0,0,99], arr

    arr = [1,1,1,4,99,5,6,0,99]
    process_program(arr)
    assert_equal [30,1,1,4,2,5,6,0,99], arr

    arr = [1,9,10,3,2,3,11,0,99,30,40,50]
    process_program(arr)
    assert_equal [3500,9,10,70,2,3,11,0,99,30,40,50], arr
  end
end

