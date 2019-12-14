Pos3D = Struct.new(:x, :y, :z)

class Moon
  attr_accessor :pos, :vel
  def initialize(x, y, z)
    @pos = Pos3D.new(x, y, z)
    @vel = Pos3D.new(0, 0, 0)
  end

  def kinetic
    @vel.x.abs + @vel.y.abs + @vel.z.abs
  end
  def potential
    @pos.x.abs + @pos.y.abs + @pos.z.abs
  end
  def simulate_gravity(other)
    @vel.x += other.pos.x <=> @pos.x
    @vel.y += other.pos.y <=> @pos.y
    @vel.z += other.pos.z <=> @pos.z
  end
  def apply_velocity
    @pos.x += @vel.x
    @pos.y += @vel.y
    @pos.z += @vel.z
  end
end

def parse_input(filename)
  moons = []
  File.foreach(filename) do |line|
    m = line.chomp.match(/<x=(-?[0-9]+), y=(-?[0-9]+), z=(-?[0-9]+)>/)
    if !m then raise "Malformed input" end
    vals = m.captures.map(&:to_i)
    moons.push( Moon.new(vals[0], vals[1], vals[2]) )
  end
  return moons
end

def run_step(moons)
  moons.each_with_index do |moon, idx|
    moons.each do |other|
    #for other_idx in idx+1..moons.length-1 do
      moon.simulate_gravity(other)
    end
  end

  moons.each do |moon|
    moon.apply_velocity 
  end
end

def run_simulation(moons, steps)
  steps.times do |steps|
    run_step(moons)
  end
end

def calc_total_energy(moons)
  total = 0
  moons.each do |moon|
    total += moon.kinetic * moon.potential
  end
  return total
end

def calc_checksum(moons)
  check = ""
  moons.each do |moon|
    check += moon.pos.x.to_s + "," + moon.pos.y.to_s + "," + moon.pos.z.to_s +
             moon.vel.x.to_s + "," + moon.vel.y.to_s + "," + moon.vel.z.to_s + ","
  end
  check
end

def find_repeated_step(moons)
  count = 0

  # Find cycles in x, y and z
  first_state = []
  moons.each do |moon|
    first_state.push(Moon.new(moon.pos.x, moon.pos.y, moon.pos.z))
  end

  x_loop = nil
  y_loop = nil
  z_loop = nil


  loop do
    run_step(moons)
    count += 1

    #puts "\n\n#{count}"
    #p moons

    #if count % 100000 == 0 then
    #  puts count
    #  puts "#{x_loop}, #{y_loop}, #{z_loop}"
    #end

    x_first = true
    y_first = true
    z_first = true

    moons.each.with_index do |moon ,idx|
      if !x_loop && moon.pos.x == first_state[idx].pos.x &&
                    moon.vel.x == first_state[idx].vel.x then
        # Nothing
      else
        x_first = false
      end
      if !y_loop && moon.pos.y == first_state[idx].pos.y &&
                    moon.vel.y == first_state[idx].vel.y then
        # Nothing
      else
        y_first = false
      end
      if !z_loop && moon.pos.z == first_state[idx].pos.z &&
                    moon.vel.z == first_state[idx].vel.z then
        # Nothing
      else
        z_first = false
      end
    end

    if x_first then x_loop = count end
    if y_first then y_loop = count end
    if z_first then z_loop = count end

    if x_loop && y_loop && z_loop then
      break
    end
  end

  puts "Finding LCM for #{x_loop}, #{y_loop}, #{z_loop}"

  # Find lowest common multiple of these numbers
  x_total = x_loop
  y_total = y_loop
  z_total = z_loop
  while x_total != y_total || y_total != z_total || z_total != x_total do
    if x_total <= y_total && x_total <= z_total then
      x_total += x_loop
    elsif y_total <= x_total && y_total <= z_total then
      y_total += y_loop
    elsif z_total <= x_total && z_total <= y_total then
      z_total += z_loop
    else
      puts "#{x_total}, #{y_total}, #{z_total}"
      raise "This should never happen"
    end
  end

  #puts z_total != x_total

  # Common multiple found
  #puts "#{x_total}, #{y_total}, #{z_total}"
  return x_total
end
