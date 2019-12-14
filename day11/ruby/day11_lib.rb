
@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

Position = Struct.new(:x, :y)

class PaintRobot
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

def run_painting_robot(program, start_white = false)
  pos_x = 0
  pos_y = 0
  direction = :up
  white_panels = []
  painted_panels = []
  halted = false

  if start_white then
    panel = Position.new(0,0)
    painted_panels.push(panel)
    white_panels.push(panel)
  end

  robot = PaintRobot.new(program)
 
  loop do
    current_position = Position.new(pos_x, pos_y)
    panel_is_white = white_panels.include?(current_position)
    robot.set_input panel_is_white ? 1 : 0

    robot.clear_output
    if robot.process_program == nil then break end
    paint_color = robot.get_output
    if paint_color == nil then raise "Paint color output error" end
    if paint_color != 0 && paint_color != 1 then raise "Paint color output error: #{paint_color}" end

    robot.clear_output
    if robot.process_program == nil then break end
    new_dir = robot.get_output
    if new_dir == nil then raise "New dir output error" end
    if new_dir != 0 && new_dir != 1 then raise "New dir output error" end
    #puts "rawdir = #{new_dir}"
    new_dir = new_dir == 0 ? :left : :right

    #puts ""
    #puts new_dir
    #puts "Adding paint to #{pos_x}, #{pos_y}"

    # Add paint
    if panel_is_white && paint_color == 0 then
      white_panels.delete(current_position)
    elsif !panel_is_white && paint_color == 1 then
      white_panels.push(current_position)
    end
    if !painted_panels.include?(current_position) then
      painted_panels.push(current_position)
    end

    #print "Turning #{new_dir} from #{direction} = "

    # Move in direction
    if    direction == :up   && new_dir == :left ||
          direction == :down && new_dir == :right
    then
       direction = :left
       pos_x += -1
    elsif direction == :right && new_dir == :left ||
          direction == :left  && new_dir == :right
    then
      direction = :up
      pos_y += 1
    elsif direction == :down && new_dir == :left ||
          direction == :up   && new_dir == :right
    then
      direction = :right
      pos_x += 1
    elsif direction == :left  && new_dir == :left ||
          direction == :right && new_dir == :right
    then
      direction = :down
      pos_y += -1
    else
      raise ArgumentError, "Error with direction logic"
    end

    #puts direction


    #puts "(#{pos_x}, #{pos_y})"
    #p robot.get_program
  end

    #puts "\n"
    #puts "Painted panels size = #{painted_panels.count}"
    ##p painted_panels

    #puts ""
    #puts "White panels size = #{white_panels.count}"
    #p white_panels

  return painted_panels, white_panels
end

def print_white_panels(white_panels)
  # Find bounds
  min_x = 99999
  max_x = 0
  min_y = 99999
  max_y = 0

  white_panels.each do |pan|
    max_x = [max_x, pan.x].max
    max_y = [max_y, pan.y].max
    min_x = [min_x, pan.x].min
    min_y = [min_y, pan.y].min
  end

  puts "max_x: #{max_x}, max_y: #{max_y}, min_x: #{min_x}, min_y: #{min_y}"

  output_arr = Array.new(1 + max_y - min_y){Array.new(1 + max_x - min_x, false)}

  white_panels.each do |pan|
    # Normalise and flip vertically
    out_x = pan.x - min_x
    out_y = (max_y - min_y) - (pan.y -= min_y)
    
    #puts "Storing at #{out_x}, #{out_y}"
    #puts "\n"
    output_arr[out_y][out_x] = true
  end

  # Print array
  output_arr.each do |row|
    row.each do |column|
      print column ? "█" : " "
    end
    print "\n"
  end
end

