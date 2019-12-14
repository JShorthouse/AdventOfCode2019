require "./day10_lib.rb"

puts "----- Part 1 -----"

input = input_to_array("../../input/10")

asteroids = array_to_objects(input)
calculate_asteroid_visibility(asteroids)

best_ast = get_best_asteroid(asteroids)

#puts ""
#p best_ast
#puts ""
#p best_ast.visible_list

puts "Highest count is #{best_ast.visible_count}"

puts "----- Part 2 -----"

ast = vaporise_asteroids(asteroids, best_ast, 200)

ans = ast.x * 100 + ast.y

puts "Answer is #{ans}"
