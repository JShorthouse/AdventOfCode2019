
def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

Position = Struct.new(:x, :y)

class LinkedNode
  attr_accessor :data, :prev, :next
  def initialize(data)
    @data = data
  end
end

class LinkedList
  attr_accessor :last
  def initialize
    @first = nil
    @last = nil
  end
  def count_nodes
    count = 0
    node = @first
    while node do
      count += 1
      node = node.next
    end
    return count
  end
  def add_node(data)
    new_node = LinkedNode.new(data)
    if !@first then
      @first = new_node
      @last = new_node
    else
      new_node.prev = @last
      @last.next = new_node
      @last = new_node
    end
  end
  def remove_end_node
    if !@first then return end
    if @first == @last then
      @first = nil
      @last = nil
    else
      prev_node = @last.prev
      prev_node.next = nil
      @last = prev_node
    end
  end
end


class OxygenRobot
  def initialize(program, non_interactive = true)
    @output = ""
    @halted = false
    @program = program
    @non_interactive = non_interactive

    @counter = 0
    @input_id = 0
    @rel_base = 0
  end

  def set_input(input)
    @input = input
  end

  def get_output
    @output
  end

  def clear_output
    @output = nil
  end

  def get_program
    @program
  end

  def read_value(mode, position)
    if mode == :position
      return @program[position] ? @program[position] : 0
    elsif mode == :immediate
      return position
    elsif mode == :relative
      return @program[@rel_base+position] ? @program[@rel_base+position] : 0
    end
  end

  def write_value(mode, position, value)
    if mode == :relative
      @program[@rel_base+position] = value
    else
      @program[position] = value
    end
  end

  def get_parameter_mode(number)
    case number
    when 0 ; :position
    when 1 ; :immediate
    when 2 ; :relative
    else
      raise ArgumentError, "Undefined parameter mode"
    end
  end

  def process_command(start) #{{{
    instruction = @program[start].digits #Reverses order

    opcode = 0
    p1_mode = :position
    p2_mode = :position
    p3_mode = :position

    if instruction.size == 1 then
      opcode = instruction[0]
    elsif instruction.size >= 2 then
      opcode = instruction[0..1].reverse.join.to_i
    end


    if instruction.size >= 3 then
      p1_mode = get_parameter_mode(instruction[2])
    else
      p1_mode = :position
    end

    if instruction.size >= 4 then
      p2_mode = get_parameter_mode(instruction[3])
    else
      p2_mode = :position
    end

    if instruction.size >= 5 then
      p3_mode = get_parameter_mode(instruction[4])
    else
      p3_mode = :position
    end

    if opcode == 99 # Return here so we don't go out of bounds
      @halted = true
      return false
    end

    arg1 = @program[start+1]
    arg2 = @program[start+2]
    store_pos = @program[start+3]

    #puts "Processing counter: #{@program[start]}"
    #puts "opcode: #{opcode}"
    ##p @program
    #puts ""

    case opcode
    when 1
      #@program[store_pos] = @program[arg1] + @program[arg2]
      sum = read_value(p1_mode, arg1) + read_value(p2_mode, arg2)
      write_value(p3_mode, store_pos, sum)
      @increment = 4
    when 2
      #@program[store_pos] = @program[arg1] * @program[arg2]
      sum = read_value(p1_mode, arg1) * read_value(p2_mode, arg2)
      write_value(p3_mode, store_pos, sum)
      @increment = 4
    when 3 # Read
      @increment = 2
      if @non_interactive then
        input = @input
      else
        printf ">"
        input = gets.to_i
        printf "\n"
      end
      write_value(p1_mode, arg1, input)
    when 4 # Output
      @increment = 2
      #@output = read_value(p1_mode, arg1)
      value = read_value(p1_mode, arg1)
      if @non_interactive then
        @output = value
        return false
      else
        puts value
      end
      #return false
    when 5 # Jump if true
      if read_value(p1_mode, arg1) != 0 then
        @counter = read_value(p2_mode, arg2)
        @increment = 0
      else
        @increment = 3
      end
    when 6 # Jump if false
      if read_value(p1_mode, arg1) == 0 then
        @counter = read_value(p2_mode, arg2)
        @increment = 0
      else
        @increment = 3
      end
    when 7 # Less than
      if read_value(p1_mode, arg1) < read_value(p2_mode, arg2) then
        write_value(p3_mode, store_pos, 1)
      else
        write_value(p3_mode, store_pos, 0)
      end
      @increment = 4
    when 8 # Equals
      if read_value(p1_mode, arg1) == read_value(p2_mode, arg2) then
        write_value(p3_mode, store_pos, 1)
      else
        write_value(p3_mode, store_pos, 0)
      end
      @increment = 4
    when 9 # Adjust relative base
      @rel_base += read_value(p1_mode, arg1)
      @increment = 2
    else
      raise ArgumentError, "Undefined opcode #{opcode}"
    end
    return true
  end#}}}

  def process_program
    if @counter != 0 then # Jump past last return
      @counter += @increment
    end

    while process_command(@counter) do
      @counter += @increment
    end
    if !@halted then return @output else return nil end
    #if @non_interactive then return @output end
  end
end

$directions = [:up, :right, :down, :left]

def turn(cur, offset)
  cur_id = $directions.index(cur)
  new_id = (cur_id + offset) % 4
  return $directions[new_id]
end

def turn_left(cur)
  turn(cur, -1)
end

def turn_right(cur)
  turn(cur, 1)
end

def combine_dirs(dir1, dir2)
  dir1_id = $directions.index(dir1)
  dir2_id = $directions.index(dir2)
  new_id = (dir1_id + dir2_id) % 4
  return $directions[new_id]
end

def get_direction_offset(direction)
  case direction
  when :up; return [0, 1]
  when :right; return [1, 0]
  when :down; return [0, -1]
  when :left; return [-1, 0]
  end
end

def dir_to_input(direction)
  # north (1), south (2), west (3), and east (4)
  case direction
  when :up; return 1
  when :right; return 4
  when :down; return 2
  when :left; return 3
  end
end

def print_map(rob_x = nil, rob_y = nil, direction = nil)
  #system("clear")
  (225..275).reverse_each do |y|
    (225..275).each do |x|
      if rob_x != nil && x == rob_x && y == rob_y then 
        case direction
          when :up; print "^"
          when :left; print "<"
          when :down; print "v"
          when :right; print ">"
        end
      else
        print $map[x][y] ? $map[x][y] : " "
      end
    end
  print "\n"
  end
end

$array_size = 500

def run_repair_droid(program, return_full_map = false)
  $map = Array.new($array_size){Array.new($array_size, nil)}

  path_taken = LinkedList.new
  direction = :up
  pos_x = $array_size / 2
  pos_y = pos_x
  halted = false

  forward_x = nil
  forward_y = nil

  ox_pos_x = nil
  ox_pos_y = nil

  step_count = 0

  last_was_x_check = false

  last_path_count = nil
  last_last_path_count = nil

  robot = OxygenRobot.new(program)

  while !halted do
    # Follow left wall
    #
    #       ^
    #     < R
    #
    # 1)  If free space to left, rotate left (unless rotated left last turn)
    # 2)  If free space ahead, move forward
    # 2a) Else, rotate right

    # Robot's program does not track rotation, only absolute movement
    # Keep processing our model until we end up with a movement
    next_move = nil
    while !next_move do

      if (!return_full_map && step_count % 5 == 0) then
        print_map(pos_x, pos_y, direction)
        sleep(0.03)
      elsif step_count % 100 == 0 then
        print_map(pos_x, pos_y, direction)
        sleep(0.1)
      end

      # Check left space
      left_dir = combine_dirs(direction, :left)
      offset = get_direction_offset(left_dir)
      left_x = pos_x + offset[0]
      left_y = pos_y + offset[1]
      if !last_was_x_check && $map[left_x][left_y] != "#" then
        #puts "Turning left: #{$map[left_x][left_y]}"
        #puts "Robot pos: (#{pos_x}, #{pos_y}), dir: #{direction}"
        #puts "Left pos: (#{left_x}, #{left_y})"
        last_was_x_check = true
        direction = turn_left(direction)
        #next
      else
        last_was_x_check = false
      end

      # Check space ahead
      offset = get_direction_offset(direction)
      forward_x = pos_x + offset[0]
      forward_y = pos_y + offset[1]
      if $map[forward_x][forward_y] != "#" then
        next_move = direction
        #puts "moving forward"
        break
      else
        # Rotate right
        direction = turn_right(direction)
        #puts "Turning right"
      end
    end

    next_input = dir_to_input(next_move)

    # Attempt to move
    robot.set_input(next_input)

    output = robot.process_program

    if !output then
      halted = true
      break
    end

    if output == 0 then # Hit wall
      $map[forward_x][forward_y] = "#"
    elsif output == 1 || output == 2 then # Move forward
      pos_x = forward_x
      pos_y = forward_y
      if $map[pos_x][pos_y] == nil then # Add to list if new location
        path_taken.add_node(Position.new(pos_x, pos_y))
        $map[pos_x][pos_y] = "."
      else # Remove from list if backtracking
        path_taken.remove_end_node
      end
    end
    #puts "Steps taken: #{path_taken.count_nodes}"

    step_count += 1

    if output == 2 then
      # Oxgen found
      ox_pos_x = pos_x
      ox_pos_y = pos_y
    end

    if !return_full_map then
      if output == 2 then
        return path_taken.count_nodes
      end
    else #Check periodicly if map is complete, return if is.
      if step_count % 50 != 0 then next end
      # If path count at 0 for a while then maze is complete
      if path_taken.count_nodes == 0 && last_path_count == 0 && last_last_path_count == 0 then
        # Write oxygen pos to map
        $map[ox_pos_x][ox_pos_y] = "O"
        return true
      else
        last_last_path_count = last_path_count
        last_path_count = path_taken.count_nodes
      end
    end
  end
end

def clone_array(arr)
  Marshal.load(Marshal.dump(arr))
end

def find_oxygen_steps
  this_map = clone_array($map)

  minutes = 0

  loop do
    last_map = this_map
    this_map = clone_array(this_map)
    minutes += 1

    # Propogate oxygen to nearby spaces
    last_map.each_with_index do |column, x|
      column.each_with_index do |tile, y|
        if tile == "O" then
          if this_map[x+1][y] == "." then this_map[x+1][y] = "O" end
          if this_map[x-1][y] == "." then this_map[x-1][y] = "O" end
          if this_map[x][y+1] == "." then this_map[x][y+1] = "O" end
          if this_map[x][y-1] == "." then this_map[x][y-1] = "O" end
        end
      end
    end

    # Check if no non-oxygenated spaces are left
    all_oxygen = true

    if minutes % 25 == 0 then
      puts "Minutes #{minutes}"
      $map = this_map
      print_map
    end

    this_map.each do |column|
      column.each do |tile|
        if tile == "." then
          all_oxygen = false
        end
      end
    end
    return minutes if all_oxygen
  end
end
