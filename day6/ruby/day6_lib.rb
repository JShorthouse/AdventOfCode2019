class Planet
  attr_accessor :parent, :id

  def initialize(id)
    @id = id
    @parent = nil
  end

  def get_parent_list
    list = []
    plan = self

    while plan.parent != nil do
      plan = plan.parent
      list.push(plan)
    end
    return list
  end

  def get_depth
    return get_parent_list.length
  end
end

$planets = {} # name -> object

def process_input(filename)
  inputs = []
  File.foreach(filename) do |line|
    inputs.push(line.chomp.split(')'))
  end
  inputs
end

def print_planets
  puts "Printing planets"
  $planets.each do |planet|
    p = planet[1]
    puts "\n--- #{p.id} --- "
    puts "#{p.parent ? p.parent.id : "None"} -> # -> ?"
    puts "Depth: #{p.get_depth}"
  end
end

def create_planets(input)
  com = Planet.new("COM")
  $planets["COM"] = com

  # Create planets
  input.each do |input|
    planet_name = input[1]

    planet = Planet.new(planet_name)

    $planets[planet_name] = planet
  end

  # Create parent links
  input.each do |input|
    parent_name = input[0]
    planet_name = input[1]

    $planets[planet_name].parent = $planets[parent_name]
  end

 #   $children[parent_name] = planet

 #   # If parent already exists, add to planet
 #   parent = $planets[parent_name]
 #   if parent then
 #     planet.parent = parent
 #   end

 #   # If this planet is a parent of an already existing child, create link
 #   child = $children[planet_name]
 #   if child then
 #     child.parent = planet
 #   end

 #   $planets[planet_name] = planet
 # end
end

def get_total_depth
  total = 0
  $planets.each do |p_pair|
    planet = p_pair[1]
    total += planet.get_depth
  end
  return total
end

def find_join_steps(p1, p2)
  #p1_list = get_parent_list(planets, planets[p1_name])
  #p2_list = get_parent_list(planets, planets[p2_name])
  p1_list = $planets[p1].get_parent_list
  p2_list = $planets[p2].get_parent_list

  p1_length = nil
  p2_length = nil

  puts "Finding join"
  # Go upwards in p1_list until common planet in p2 is found
  for i in 0..p1_list.size-1 do
    p2_pos = p2_list.index(p1_list[i])
    if p2_pos != nil then
      p1_length = i
      p2_length = p2_pos
      break
    end
  end

  join_steps = p1_length + p2_length
end
