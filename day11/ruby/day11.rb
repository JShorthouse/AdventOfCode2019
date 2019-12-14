require "./day11_lib.rb"

puts "----- Part 1 -----"

program = read_to_array("../../input/11")

panels, w = run_painting_robot(program.clone)

panel_count = panels.count

puts "Total panels counted is #{panel_count}"


puts "----- Part 2 -----"

panels, white_panels = run_painting_robot(program.clone, true)

print_white_panels(white_panels)
