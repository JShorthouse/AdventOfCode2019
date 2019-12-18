require "./day17_lib.rb"

puts "----- Part 1 -----"

program = read_to_array("../../input/17")

alignment_sum = run_camera(program.clone)

puts "Alignment sum is #{alignment_sum}"

puts "----- Part 2 -----"

altered_program = program.clone

altered_program[0] = 2

#alignment_sum = run_camera(altered_program)
output = move_robot(altered_program)

puts "Dust collected is #{output}"
