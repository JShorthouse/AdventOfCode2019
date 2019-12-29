require "./day25_lib.rb"

puts "----- Part 1 -----"

original_program = read_to_array("../../input/25")

item_list = [
  "candy cane",
  "fuel cell",
  "manifold",
  "mutex",
  "coin",
  "dehydrated water",
  "prime number",
  "cake"
]

door_instructions = [
  "north",
  "take candy cane",
  "south",
  "south",
  "take fuel cell",
  "south",
  "take manifold",
  "north",
  "north",
  "west",
  "take mutex",
  "south",
  "south",
  "take coin",
  "west",
  "take dehydrated water",
  "south",
  "take prime number",
  "north",
  "east",
  "north",
  "east",
  "take cake",
  "north",
  "west",
  "south",
  "drop candy cane",
  "drop fuel cell",
  "drop manifold",
  "drop mutex",
  "drop coin",
  "drop dehydrated water",
  "drop prime number",
  "drop cake",
  "north",
  "south",
  "inv"
]

solve_game(original_program.clone, door_instructions, item_list, true)
