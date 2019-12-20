require "test/unit"
require "./day19_lib.rb"


class LibTests < Test::Unit::TestCase

  def run_program(program)
    comp = IntComp.new(program.clone)
    comp.process_program
    return comp.get_program
  end

  def run_interactive_program(program, input)
    comp = IntComp.new(program.clone, true)
    comp.set_input input
    out_str = ""
    loop do
      status, output = comp.process_program
      break if status == :halted
      out_str += output.to_s + "\n"
    end
    return out_str
  end


  def test_process_program
    assert_equal [2,0,0,0,99], run_program([1,0,0,0,99])
    assert_equal [30,1,1,4,2,5,6,0,99], run_program([1,1,1,4,99,5,6,0,99])
    assert_equal [3500,9,10,70,2,3,11,0,99,30,40,50], run_program([1,9,10,3,2,3,11,0,99,30,40,50])
  end

  def test_immediate_mode
    assert_equal [1002,4,3,4,99], run_program([1002,4,3,4,33])
  end

  def test_additional_commands
    arr = [3,9,8,9,10,9,4,9,99,-1,8]
    assert_equal "1\n",  run_interactive_program(arr, 8)
    assert_equal "0\n",  run_interactive_program(arr, 7)

    arr = [3,9,7,9,10,9,4,9,99,-1,8]
    assert_equal "0\n",  run_interactive_program(arr, 8)
    assert_equal "1\n", run_interactive_program(arr, 7)
    assert_equal "0\n", run_interactive_program(arr, 10)

    arr = [3,3,1108,-1,8,3,4,3,99]
    assert_equal "1\n", run_interactive_program(arr, 8)
    assert_equal "0\n", run_interactive_program(arr, 6)

    arr = [3,3,1107,-1,8,3,4,3,99]
    assert_equal "0\n", run_interactive_program(arr, 8)
    assert_equal "1\n", run_interactive_program(arr, 7)

    arr = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
           1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
           999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
    assert_equal "999\n", run_interactive_program(arr, 7)
    assert_equal "1000\n", run_interactive_program(arr, 8)
    assert_equal "1001\n", run_interactive_program(arr, 9)
  end

  def test_relative_base
    arr = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    assert_equal arr.join("\n").encode("UTF-8") + "\n", run_interactive_program(arr, nil)

    arr = [1102,34915192,34915192,7,4,7,99,0]
    assert_true run_interactive_program(arr, nil).chomp.to_i.digits.length == 16

    arr = [104,1125899906842624,99]
    assert_equal "1125899906842624\n", run_interactive_program(arr, nil)
  end
end
