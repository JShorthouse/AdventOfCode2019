require "./day4_lib.rb"

input_min = 156218
input_max = 652527

puts "----- Part 1 -----"

# Brute force

num_passwords = 0

for pass in input_min..input_max do
  if valid_password(pass) then num_passwords += 1 end
end

puts "Total passwords: #{num_passwords}"

puts "----- Part 2 -----"

num_passwords = 0

for pass in input_min..input_max do
  if valid_password_2(pass) then num_passwords += 1 end
end

puts "Total passwords: #{num_passwords}"
