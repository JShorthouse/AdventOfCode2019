require "test/unit"
require "./day5_lib.rb"

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

  def test_immediate_mode
    arr = [1002,4,3,4,33]
    process_program(arr)
    assert_equal [1002,4,3,4,99], arr
  end

  def test_additional_commands
    arr = [3,9,8,9,10,9,4,9,99,-1,8]
    set_input 8
    assert_equal "1\n", process_program(arr, true)
    set_input 7 
    assert_equal "0\n", process_program(arr, true)

    arr = [3,9,7,9,10,9,4,9,99,-1,8]
    set_input 8
    assert_equal "0\n", process_program(arr, true)
    set_input 7 
    assert_equal "1\n", process_program(arr, true)
    set_input 10
    assert_equal "0\n", process_program(arr, true)

    arr = [3,3,1108,-1,8,3,4,3,99]
    set_input 8
    assert_equal "1\n", process_program(arr, true)
    set_input 6 
    assert_equal "0\n", process_program(arr, true)

    arr = [3,3,1107,-1,8,3,4,3,99]
    set_input 8
    assert_equal "0\n", process_program(arr, true)
    set_input 7 
    assert_equal "1\n", process_program(arr, true)

    arr = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
           1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
           999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

    set_input 7
    assert_equal "999\n", process_program(arr, true)
    set_input 8
    assert_equal "1000\n", process_program(arr, true)
    set_input 9
    assert_equal "1001\n", process_program(arr, true)
  end
end
