require "./day8_lib.rb"

puts "----- Part 1 -----"

input = array_from_file("../../input/8")

#puts input.length

img = load_image(25, 6, input)

min_zero_amount = 999999 # Reee
min_zero_layer = nil

#p img

img.each do |lay|
 # puts "Counting layer #{lay}"
  total_count = count_in_layer(0, lay)
  if total_count < min_zero_amount
    min_zero_amount = total_count
    min_zero_layer = lay
  end
end

output = count_in_layer(1, min_zero_layer) * count_in_layer(2, min_zero_layer)

puts "Checksum is #{output}"

puts "----- Part 2 -----"
puts ""

output_img = squash_image(img)
#p output_img
render_image(output_img)

