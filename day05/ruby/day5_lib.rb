@increment = 4

@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

def read_value(arr, mode, position)
  if mode == :position
    return arr[position]
  elsif mode == :immediate
    return position
  end
end

def set_input(input)
  @input = input
end

def process_command(array, start, non_interactive = false)
  instruction = array[start].digits #Reverses order

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
    return false
  end

  arg1 = array[start+1]
  arg2 = array[start+2]
  store_pos = array[start+3]

  case opcode
  when 1
    #array[store_pos] = array[arg1] + array[arg2]
    sum = read_value(array, p1_mode, arg1) + read_value(array, p2_mode, arg2)
    array[store_pos] = sum
    @increment = 4
  when 2
    #array[store_pos] = array[arg1] * array[arg2]
    sum = read_value(array, p1_mode, arg1) * read_value(array, p2_mode, arg2)
    array[store_pos] = sum
    @increment = 4
  when 3
    input = 0
    if non_interactive then
      input = @input
    else
      printf ">"
      input = gets.to_i
      printf "\n"
    end
    array[arg1] = input
    @increment = 2
  when 4
    value = read_value(array, p1_mode, arg1)
    if non_interactive then
      @output += value.to_s + "\n"
    else
      puts value 
    end
    @increment = 2
  when 5 # Jump if true
    if read_value(array, p1_mode, arg1) != 0 then
      @counter = read_value(array, p2_mode, arg2)
      @increment = 0
    else
      @increment = 3
    end
  when 6 # Jump if false
    if read_value(array, p1_mode, arg1) == 0 then
      @counter = read_value(array, p2_mode, arg2)
      @increment = 0
    else
      @increment = 3
    end
  when 7 # Less than
    if read_value(array, p1_mode, arg1) < read_value(array, p2_mode, arg2) then
      array[store_pos] = 1
    else
      array[store_pos] = 0
    end
    @increment = 4
  when 8 # Equals
    if read_value(array, p1_mode, arg1) == read_value(array, p2_mode, arg2) then
      array[store_pos] = 1
    else
      array[store_pos] = 0
    end
    @increment = 4
  else
    raise ArgumentError, "Undefined opcode #{opcode}"
  end
end

def process_program(array, non_interactive = false)
  @output = ""
  @counter = 0
  while process_command(array, @counter, non_interactive) do
    @counter += @increment
  end
  if non_interactive then return @output end
end
