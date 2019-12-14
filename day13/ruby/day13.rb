require "./day13_lib.rb"

puts "----- Part 1 -----"

program = read_to_array("../../input/13")

screen, _ = run_game(program.clone)

total_count = 0

screen.each do |row|
  total_count += row.count(2)
end

puts "Total number of block tiles is #{total_count}"

puts "----- Part 2 -----"

freeplay = program.clone
freeplay[0] = 2

screen, score = run_game(freeplay)

puts "Final score is #{score}"

