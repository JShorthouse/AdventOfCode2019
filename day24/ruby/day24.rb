require "./day24_lib.rb"

puts "----- Part 1 -----"

grid = process_input("../../input/24")
common_rating = run_until_duplicate(grid)

puts "Biodiversity rating is #{common_rating}"

puts "----- Part 2 -----"

grid = process_input("../../input/24")

grids = gen_recursive_grid(grid, 200)
grids = run_recursive(grids, 200)
num_bugs = count_total_bugs(grids)

puts "Number of bugs after 200 minutes is #{num_bugs}"
