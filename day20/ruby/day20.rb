require "./day20_lib.rb"

map = process_input("../../input/20")

puts "----- Part 1 -----"

zz_distance = find_length_to_exit(map)

puts "Distance to exit is #{zz_distance}"
