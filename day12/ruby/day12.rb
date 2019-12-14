require "./day12_lib.rb"

puts "----- Part 1 -----"

moons = parse_input("../../input/12")

run_simulation(moons, 1000)

total = calc_total_energy(moons)
puts "Total energy is #{total}"

puts "----- Part 2 -----"

# Deep clone
moons = parse_input("../../input/12")

steps = find_repeated_step(moons)

puts "Number of steps for repetition is #{steps}"
