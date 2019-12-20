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
    @increment = 0
    @rel_base = 0
    @status = nil

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
    @counter += @increment # Jump past last return
    while process_command(@counter) do
      @counter += @increment
    end
    return @status, @output
  end

  def run_until_next_input
    status = nil
    while status != :need_input do
      status, _ = process_program
      if status == :halted then raise "Halted unexpectedly" end
    end
  end
end

def count_affected_points(program, max_x, max_y)
  total_count = 0
  for x in 0..max_x do
    for y in 0..max_y do
      comp = IntComp.new(program.clone, true) # New program for each check
      comp.run_until_next_input
      comp.set_input x

      comp.run_until_next_input
      comp.set_input y

      _, output = comp.process_program

      if output == 1 then
        total_count += 1
        print "#"
      elsif output != 0 then
        raise "Unexpected output"
      else
        print "."
      end
    end
    print "\n"
  end
  return total_count
end

def beam_passes(program, x, y)
  #puts "Checking if beam passes #{x}, #{y}"
  comp = IntComp.new(program.clone, true) # New program for each check
  comp.run_until_next_input
  comp.set_input x

  comp.run_until_next_input
  comp.set_input y

  _, output = comp.process_program

  if output == 1 then
    return true
  elsif output == 0 then
    return false
  else
    raise "Unexpected output"
  end
end

def fit_object_in_beam(program, object_x, object_y)
  cur_x = 0
  cur_y = 10 # Skip ahead to skip area with no beam near start

  # Travel down right side of beam
  loop do
    # Find coordinates on beam
    cur_y += 1
    # Find edge of beam
    has_been_on_beam = false
    loop do
      on_beam = beam_passes(program, cur_x, cur_y)

      # Ensure that we are on the right side of the beam and not the left
      if !on_beam && has_been_on_beam then
        break
      end

      if on_beam then
        has_been_on_beam = true
      end

      cur_x += 1

      #puts "On beam: #{on_beam}, has been: #{has_been_on_beam}"
    end
    # Bring back to on beam
    cur_x -= 1

    #puts "Found"

    # Check if object would fit in
    if cur_x < object_x || cur_y < object_y then next end

    # cur_x and cur_y form top right corner, check if bottom left would be in beam
    bot_x = cur_x - (object_x - 1)
    bot_y = cur_y + (object_y - 1)

    #puts "Checking (#{cur_x}, #{cur_y} and (#{bot_x}, #{bot_y})"

    in_beam = beam_passes(program, bot_x, bot_y)

    if !in_beam then next end

    # Is in beam, return top left coordinate, our answer
    return bot_x, cur_y
  end
end
