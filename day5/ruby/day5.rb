require "./day5_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/5")
program = original_program.clone

puts "Running program"

process_program(program)


puts "----- Part 2 -----"

program = original_program.clone
process_program(program)
