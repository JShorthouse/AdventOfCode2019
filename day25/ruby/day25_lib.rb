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


def feed_input(bot, input)
  input.each do |char|
    status, _ = bot.process_program
    if status != :need_input then 
      raise "Unexpected state #{status} when feeding input" 
    end
    bot.set_input( char )
  end
  #sleep(0.25)
end

def get_ascii_input()
  print "> "
  return gets.split('').map(&:bytes).flatten
end

def str_to_ascii(input, newline = true)
  output = input.split('').map(&:bytes).flatten
  if newline then output.push("\n".bytes[0]) end
  return output
end

def run_until_input(comp, show_output)
  loop do
    status, output = comp.process_program
    #puts status
    case status
    when :output
      if output < 256 then
        print output.chr if show_output
      else
        puts output
      end
    when :need_input
      return
    when :halted 
      puts "Program halt."
      return :halted
    end
  end
end

def get_to_door(comp, instructions, show_output)
  instructions.each do |inst_string|
    print inst_string if show_output
    feed_input(comp, str_to_ascii(inst_string))

    run_until_input(comp, show_output)
  end
end

def try_items(comp, item_list, show_output)
  move_cmd = str_to_ascii("west")
  take_cmd = str_to_ascii("take ", false)
  drop_cmd = str_to_ascii("drop ", false)

  # Add all items to inv
  item_list.each do |item_string|
    print "take " + item_string if show_output
    feed_input(comp, take_cmd + str_to_ascii(item_string))

    run_until_input(comp, show_output)
  end

  feed_input(comp, move_cmd)
  output = run_until_input(comp, show_output)
  if output == :halted then return :halted end

  # Drop all items
  item_list.each do |item_string|
    print "drop " + item_string if show_output
    feed_input(comp, drop_cmd + str_to_ascii(item_string))

    run_until_input(comp, show_output)
  end
end


def solve_game(program, door_instructions, item_list, show_output)
  comp = IntComp.new(program, true)

  run_until_input(comp, show_output)
  get_to_door(comp, door_instructions, show_output)

  (0..item_list.length).flat_map{|size| item_list.combination(size).to_a }.each do |items|
    output =  try_items(comp, items, show_output)
    if output == :halted then return end
  end
end


def run_interactive_program(program, program_input = nil)
  comp = IntComp.new(program, true)
  loop do
    status, output = comp.process_program
    #puts status
    case status
    when :output
      if output < 256 then
        print output.chr
      else
        puts output
      end
    when :need_input
      input = nil
      if program_input == nil then
        input = get_ascii_input
      else
        # Remove first element
        input = str_to_ascii(program_input.shift)
      end
      feed_input(comp, input)
    when :halted 
      puts "Program halt."
      return
    end
  end
end
