
@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end


class IntComp
  def initialize(program, non_interactive = false)
    @output = ""
    @halted = false
    @program = program
    @non_interactive = non_interactive

    @counter = 0
    @rel_base = 0

    @break_counter = 11
  end

  def set_input(input)
    @input = input
  end

  def get_output
    @output
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
    true
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

def render_screen(screen, score)
  #print "\n\n"
  system("clear")
  screen.each do |row|
    row.each_with_index do |pixel, index|
      case pixel
      when 0
        print " "
      when 1
        print "+"
      when 2
        print "X"
      when 3
        print "-"
      when 4
        print "O"
      else
        raise "Invalid pixel value"
      end
    end
    print "\n"
  end
  print "Score: #{score}"
  sleep(0.03)
end

def run_game(program)
  game = IntComp.new(program, true)

  screen = Array.new(30){Array.new(80, 0)}

  score = 0
  ball_x = 0
  paddle_x = 0

  running = true
  while running do
    x_pos = game.process_program
    if x_pos == nil then
      running = false
      break
    end

    y_pos = game.process_program
    raise "y_pos is nil" unless y_pos != nil

    value = game.process_program
    raise "value is nil" unless value != nil

    if x_pos == -1 && y_pos == 0 then
      score = value
    else
      screen[y_pos][x_pos] = value
    end

    if value == 3 then paddle_x = x_pos
    elsif value == 4 then ball_x = x_pos end

    #render_screen(screen, score)

    # Set input based on ball's position
    game.set_input ball_x <=> paddle_x
  end
  return screen, score
end

