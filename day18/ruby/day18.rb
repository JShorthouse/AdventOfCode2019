require "./day18_lib.rb"

puts "----- Part 1 -----"

maze = process_input("../../input/18")

objects = find_maze_objects(maze)
calculate_paths(maze, objects)
shortest = calculate_shortest_path(objects) 

puts "Shortest distance is #{shortest}"
