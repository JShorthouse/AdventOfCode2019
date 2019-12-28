require "./day23_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/23")

y_val = simulate_network(original_program.clone, 50, 255)

puts "Y value for first 225 instruction is #{y_val}"

puts "----- Part 2 -----"

y_val = simulate_network(original_program.clone, 50, nil)

puts "First y value sent twice by nat is #{y_val}"
