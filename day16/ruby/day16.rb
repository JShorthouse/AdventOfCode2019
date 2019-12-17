require "./day16_lib.rb"


puts "----- Part 1 -----"

input = read_input("../../input/16")

output = apply_fft_phases(input.clone, 100)

answer = first_digits(output, 8)

puts "The first 8 digits of the output are #{answer}"


puts "----- Part 2 -----"

output = apply_big_fft(input.clone, 10000, 100)

answer = first_digits(output, 8)

puts "The first 8 digits of the output are #{answer}"
