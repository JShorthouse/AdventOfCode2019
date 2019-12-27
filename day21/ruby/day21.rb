require "./day21_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/21")

input = [
  "NOT A J",
  "NOT B T",
  "OR T J",
  "NOT C T",
  "OR T J",
  "AND D J",
  "WALK"
]

run_interactive_program(original_program.clone, input)
#run_interactive_program(original_program.clone, nil)

puts "----- Part 2 -----"

input = [
  "NOT A J",
  "NOT B T",
  "OR T J",
  "NOT C T",
  "OR T J",
  "AND D J",
  "OR J T",  # Set T to true assuming J is true
  "NOT T T", #  (if it isn't true then it doesn't matter because jump will fail 
  "OR E T",  #  at final AND regardless) 
  "OR H T",
  "AND T J",
  "RUN"
]

run_interactive_program(original_program.clone, input)
