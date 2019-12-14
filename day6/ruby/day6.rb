require "./day6_lib.rb"

puts "----- Part 1 -----"

input = process_input("../../input/6")
create_planets(input)
total_depth = get_total_depth

puts "Total number of orbits is #{total_depth}"

puts "----- Part 2 -----"

transfers = find_join_steps("YOU", "SAN")

puts "Total number of transfers is #{transfers}"
