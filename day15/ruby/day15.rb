require "./day15_lib.rb"


original_program = read_to_array("../../input/15")

count = run_repair_droid(original_program.clone)

run_repair_droid(original_program.clone, true)
minutes = find_oxygen_steps


puts "----- Part 1 -----"
puts "Total count is #{count}"

puts "----- Part 2 -----"
puts "Minutes to fill with oxygen #{minutes}"
