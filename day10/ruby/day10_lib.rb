class Asteroid
  attr_accessor :x, :y, :visible_list
  def initialize(x, y)
    @x = x
    @y = y
  end
  def visible_count 
    @visible_list.count 
  end
  def to_s
    "(#{x}, #{y})"
  end
end

def input_to_array(filename)
  array = []
  File.readlines(filename).each do |line|
    array.push(line.chomp.split(''))
  end
  return array
end

def array_to_objects(array)
  asteroids = []
  array.each_with_index do |row, y|
    row.each_with_index do |char, x|
      if char == "#" then
        asteroids.push(Asteroid.new(x, y))
      end
    end
  end
  return asteroids
end

Other_Asteroid = Struct.new(:asteroid, :distance)

def get_visible_list(asteroids, ast)
  temp_asteroids = {} # Mapping of angles to other asteroids

  asteroids.each do |other_ast|
    if other_ast == ast then next end

    # Calculate angle
    rel_x = other_ast.x - ast.x
    rel_y = other_ast.y - ast.y
    #angle = ((((Math.atan2(rel_y, rel_x) / (2 * Math::PI)) * 360) + 450) % 360).round(8)

    # Get angle from positive Y axis
    angle = (((((Math.atan2(rel_x, -rel_y) / (2 * Math::PI)) * 360) + 360)) %360).round(8)
    dist = rel_y.abs + rel_x.abs # Manhattan

    ast_obj = Other_Asteroid.new
    ast_obj.asteroid = other_ast
    ast_obj.distance = dist

    if temp_asteroids[angle] == nil ||
       temp_asteroids[angle].distance > ast_obj.distance 
    then
       temp_asteroids[angle] = ast_obj
    end
  end
  return temp_asteroids
end

def calculate_asteroid_visibility(asteroids)
  asteroids.each do |ast|
    ast.visible_list = get_visible_list(asteroids, ast)
  end
end

def get_best_asteroid(asteroids)
  best_ast = nil
  highest_count = 1

  asteroids.each do |ast|
    this_count = ast.visible_list.count
    if this_count > highest_count then
      highest_count = this_count 
      best_ast = ast
    end
  end
  return best_ast
end

def vaporise_asteroids(asteroids, base, target)
  count = 1
  target_asteroid = nil
  found = false

  while !found do
    #puts "Looping"
    if count == target then break end

    visible = get_visible_list(asteroids, base)
    sorted_asteroids = visible.sort_by{|key| key}

    sorted_asteroids.each do |arr|
      asteroid = arr[1].asteroid
      angle = arr[0]

      if count != target then
        asteroids.delete(asteroid) # Vaporise
      else
        target_asteroid = asteroid
        found = true
        break
      end
      count += 1
    end
  end
  return target_asteroid
end
