require "./day7_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/7")

max_signal = 0

# Test all phases
[0,1,2,3,4].permutation do |a,b,c,d,e|
  program = original_program.clone
  signal = simulate_amps(program, [a,b,c,d,e])
  if signal > max_signal then max_signal = signal end
end

puts "Highest signal is #{max_signal}"

puts "----- Part 2 -----"
max_signal = 0

[5,6,7,8,9].permutation do |a,b,c,d,e|
  program = original_program.clone
  signal = simulate_amp_loop(program, [a,b,c,d,e])
  if signal > max_signal then max_signal = signal end
end

puts "Total signal is #{max_signal}"
