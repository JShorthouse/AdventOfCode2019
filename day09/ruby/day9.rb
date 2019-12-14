require "./day9_lib.rb"

puts "----- Part 1 -----"

program = read_to_array("../../input/9")

comp = IntComp.new(program.clone)
comp.process_program

#p comp.get_program

puts "----- Part 2 -----"

comp = IntComp.new(program.clone)
comp.process_program
