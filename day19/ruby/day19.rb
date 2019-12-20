require "./day19_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/19")

beam_points = count_affected_points(original_program.clone, 49, 49)

puts "Number of points affected by beam is #{beam_points}"

puts "----- Part 2 -----"


fit_x, fit_y = fit_object_in_beam(original_program.clone, 100, 100)

answer = fit_x * 10000 + fit_y

puts "Answer is #{answer}"
