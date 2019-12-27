require "./day22_lib.rb"

puts "----- Part 1 -----"

stack = CardStack.new(10007)

process_input(stack, "../../input/22")

card_pos = stack.get_pos_of(2019)

puts "Position of card 2019 is: #{card_pos}"
