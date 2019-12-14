require "./day14_lib.rb"

puts "----- Part 1 -----"

input = input_to_string("../../input/14")

process_input(input)

ore, _ = calculate_needed_ore

puts "Needed ore is #{ore}"

puts "----- Part 2 -----"

total_ore = 1000000000000

max_fuel = calculate_fuel_for_ore(total_ore)

puts "Maximum fuel that can be produced is: #{max_fuel}"

