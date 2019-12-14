require "./day2_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/2")
program = original_program.clone

# Make specified adjustments
program[1] = 12
program[2] = 2

process_program(program)

puts "Value at position 0 is #{program[0]}"



puts "----- Part 2 -----"

target = 19690720

found = false
found_noun = 0
found_verb = 0

# Bruteforce
99.times do |noun|
  break if found
  99.times do |verb|
    this_program = original_program.clone
    this_program[1] = noun
    this_program[2] = verb

    process_program(this_program)
    if this_program[0] == target then
      #puts "Found #{noun} #{verb}"
      #puts this_program[0]
      found_noun = noun
      found_verb = verb
      found = true
      break
    end
  end
end

answer = 100 * found_noun + found_verb

puts "The combined verb + noun solution is #{answer}"
