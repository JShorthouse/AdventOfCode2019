def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

def process_command(array, start)
  opcode = array[start]

  if opcode == 99 # Return here so we don't go out of bounds
    return false
  end

  arg1 = array[start+1]
  arg2 = array[start+2]
  store_pos = array[start+3]

  case opcode
  when 1
    array[store_pos] = array[arg1] + array[arg2]
    return true
  when 2
    array[store_pos] = array[arg1] * array[arg2]
  else
    raise ArgumentError, "Undefined opcode" 
  end
end

def process_program(array)
  counter = 0
  while process_command(array, counter) do
    counter += 4
  end
end
