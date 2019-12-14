require "./day1_lib.rb"

puts "----- Part 1 -----"

@total_fuel = 0

File.foreach('../../input/1') do |line|
  @total_fuel += calc_fuel(line.to_f)
end

puts "Total fuel needed is: #{@total_fuel}"

puts "----- Part 2 -----"

@total_fuel = 0

File.foreach('../../input/1') do |line|
  @total_fuel += recursive_fuel(line.to_f)
end

puts "Total fuel needed is: #{@total_fuel}"
