require 'chunky_png'

@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

Position = Struct.new(:x, :y)

class IntComp
  def initialize(program, non_interactive = false)
    @output = ""
    @halted = false
    @program = program
    @non_interactive = non_interactive

    @counter = 0
    @rel_base = 0
    @status = nil

    @break_counter = 11
    @input = nil
  end

  def set_input(input)
    @input = input
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
      raise ArgumentError, "Undefined parameter mode #{number}"
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
      @status = :halted
      return false
    end

    #puts "Opcode: #{opcode}"

    arg1 = @program[start+1]
    arg2 = @program[start+2]
    store_pos = @program[start+3]

    #puts "Processing counter: #{@program[start]}"
    #p @program
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
      #puts "Read command #{start}, #{arg1}, #{p1_mode}"
      #@increment = 2
      input = nil
      if @non_interactive then
        # Read input if set, else return
        if @input then
          #puts "  Have input #{@input}"
          input = @input
          @input = nil # Clear input
        else
          #puts "Need input"
          @increment = 0
          @status = :need_input
          return false
        end
      else
        printf ">"
        input = gets.to_i
        printf "\n"
      end
      raise "Input not set" if input == nil
      #puts "Writing value #{input} to #{arg1} with mode #{p1_mode}"
      write_value(p1_mode, arg1, input)
      @increment = 2
    when 4 # Output
      @increment = 2
      #@output = read_value(p1_mode, arg1)
      value = read_value(p1_mode, arg1)
      if @non_interactive then
        @output = value
        @status = :output
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
      #puts "Comparing #{read_value(p1_mode, arg1)} and #{read_value(p2_mode, arg2)}"
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
    true
  end#}}}

  def process_program
    if @counter != 0 then # Jump past last return
      @counter += @increment
    end
    while process_command(@counter) do
      @counter += @increment
    end
    return @status, @output
  end
end

def render_scaffolding(screen)
  #print "\n\n"
  #system("clear")
  screen.each do |row|
    row.each_with_index do |pixel, index|
      print pixel
    end
    print "\n"
  end
  sleep(0.03)
end

def render_to_image(screen)
  png = ChunkyPNG::Image.new(screen[0].length, screen.length-1, ChunkyPNG::Color::TRANSPARENT)
  for y in (0..screen.length-2) do
    for x in (0..screen[0].length-1) do
      case screen[y][x]
      when '#'; color = ChunkyPNG::Color('blue')
      when '.'; color = ChunkyPNG::Color('black')
      else color = ChunkyPNG::Color('white')
      end
      png[x,y] = color
    end
  end
  png.save('scaffold.png')
end

def find_junctions(arr)
  junctions = []
  #arr_clone = arr.clone
  for y in (1..arr.length-2) do
    for x in (1..arr[0].length-2) do
      if arr[y][x] != '#' then next end
      if arr[y+1][x] != '#' then next end
      if arr[y-1][x] != '#' then next end
      if arr[y][x+1] != '#' then next end
      if arr[y][x-1] != '#' then next end

      # Is junction
      junctions.push(Position.new(x, y))
      #arr_clone[y][x] = "O"
    end
  end
  #render_scaffolding(arr_clone)
  return junctions
end

def total_junction_offsets(junctions)
  junctions.reduce(0) {|sum, junct| sum += junct.x * junct.y }
end

def run_camera(program)
  camera = IntComp.new(program, true)

  screen_arr = []
  screen_arr[0] = []

  running = true
  while running do
    row_num = 0

    loop do
      #puts "looping"
      status, output = camera.process_program

      #puts "Status is #{status}"

      if status != :output then
        running = false
        break
      end

      if output == 10 then
        row_num += 1
        screen_arr[row_num] = []
        next
      end

      ascii_char = output.chr

      screen_arr[row_num].push(ascii_char)
    end
  end

  render_scaffolding(screen_arr)

  junctions = find_junctions(screen_arr)

  #p junctions

  #render_to_image(screen_arr)

  return total_junction_offsets(junctions)
end

def format_input_string(input)
  # Map each char to ascii bytes
  input = input.map{|i| i.chars.map(&:bytes).flatten}
 
  # Add commas between each
  input = input.zip([44] * input.length).flatten

  # Add ascii return to end
  input[-1] = 10

  return input
end

def feed_input(bot, input)
  input.each do |char|
    status = nil
    loop do
      status, output = bot.process_program
      #puts "input output: #{output}" if status == :output
      if status == :output then
        print output.chr
      end
      break if status == :need_input
      if status == :halted then exit 0 end
    end
    bot.set_input( char )
  end
end

def move_robot(program)
  # Hardcoded values derived from manually finding patterns in output
  movement_a = format_input_string( %w(R 6  L 10 R 10 R 10) )
  movement_b = format_input_string( %w(R 6  L 12 L 10) )
  movement_c = format_input_string( %w(L 10 L 12 R 10) )

  main_movement = format_input_string( %w(A C A C A B A B C B) )

  bot = IntComp.new(program, true)

  loop do
    status, output = bot.process_program
    #puts "input output: #{output}" if status == :output
    if status == :output then
      print output.chr
    end
    break if status == :need_input
    if status == :halted then throw "Halted" end
  end

  #p main_movement
  #p main_movement.map(&:chr)
  #puts "Feeding in main"
  feed_input( bot, main_movement )
  #puts "Feeding in a"
  #p movement_a
  feed_input( bot, movement_a )
  #puts "Feeding in b"
  feed_input( bot, movement_b )
  #puts "Feeding in c"
  feed_input( bot, movement_c )

  feed_input(bot , ["n".bytes[0], "\n".bytes[0]]) # Disable output

  # Run bot
  status = nil
  output = nil
  loop do
    status, output = bot.process_program
    print output.chr if output < 255
    if status == :halted then break end
  end

  return output
end
