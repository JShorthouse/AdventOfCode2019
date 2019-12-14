
@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end


class Amplifier

  def initialize(p)
    @output = nil
    @phase = nil
    @signal = nil
    @halted = false

    @counter = 0
    @phase = p
    @input_id = 0

    @program = nil
  end


  def get_next_input
    inp = nil
    if @input_id == 0 then inp = @phase end
    if @input_id >= 1 then inp = @signal end

    @input_id += 1
    return inp
  end

  def read_value(mode, position)
    if mode == :position
      return @program[position]
    elsif mode == :immediate
      return position
    end
  end

  def set_program(program)
    @program = program
  end

  def process_command(start) #{{{
    array = @program
    instruction = @program[start].digits #Reverses order

    opcode = 0
    p1_mode = 0
    p2_mode = 0
    p3_mode = 0

    if instruction.size == 1 then
      opcode = instruction[0]
    elsif instruction.size >= 2 then
      opcode = instruction[0..1].reverse.join.to_i
    end


    if instruction.size >= 3 and instruction[2] == 1 then
      p1_mode = :immediate
    else
      p1_mode = :position
    end

    if instruction.size >= 4 and instruction[3] == 1 then 
      p2_mode = :immediate
    else
      p2_mode = :position
    end

    if instruction.size >= 5 and instruction[4] == 1 then
      p3_mode = :immediate
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

    #puts "Processing counter: #{@counter}, opcode #{opcode} in:"
    #p @program
    #puts ""

    case opcode
    when 1
      #@program[store_pos] = @program[arg1] + @program[arg2]
      sum = read_value(p1_mode, arg1) + read_value(p2_mode, arg2)
      @program[store_pos] = sum
      @increment = 4
    when 2
      #@program[store_pos] = @program[arg1] * @program[arg2]
      sum = read_value(p1_mode, arg1) * read_value(p2_mode, arg2)
      @program[store_pos] = sum
      @increment = 4
    when 3 # Read
      input = get_next_input()
      @program[arg1] = input
      @increment = 2
    when 4 # Output
      @output = read_value(p1_mode, arg1)
      @increment = 2
      return false
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
        @program[store_pos] = 1
      else
        @program[store_pos] = 0
      end
      @increment = 4
    when 8 # Equals
      if read_value(p1_mode, arg1) == read_value(p2_mode, arg2) then
        @program[store_pos] = 1
      else
        @program[store_pos] = 0
      end
      @increment = 4
    else
      raise ArgumentError, "Undefined opcode #{opcode}"
    end 
  end#}}}

  def process_program(signal)
    @signal = signal
    if @counter != 0 then # Jump past last return
      @counter += @increment
    end
    while process_command(@counter) do
      @counter += @increment
    end
    if !@halted then return @output else return nil end
  end
end

def simulate_amps(program, phases)
  output = 0
  count = 0
  phases.each do |phase|
    amp = Amplifier.new(phase)
    amp.set_program(program.clone)
    output = amp.process_program(output) # Pass signal from last amp
    count += 1
  end
  return output
end


def simulate_amp_loop(program, phases)
  num_output = 0
  count = 0
  amps = []

  amps_halted = false

  phases.each do |phase|
    amp = Amplifier.new(phase)
    amp.set_program(program.clone)
    amps.push(amp)
  end

  while !amps_halted do
    amps.each do |amp|
      if count > 5000 then return end
      #puts "\n\n\nSimluating amp #{count} ------------------------------------------"

      output = amp.process_program(num_output) # Pass signal from last amp
      if output == nil then
        amps_halted = true
      else
        num_output = output
      end
      count += 1
    end
  end

  return num_output
end
