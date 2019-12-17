def read_input(filename)
  File.open(filename).read.chomp.split('').map(&:to_i)
end 
def i_to_arr(int)
  int.to_s.split('').map(&:to_i)
end

def get_pattern(repetitions, length, pattern_offset = 0)
  base_pattern = [0,1,0,-1]

  pattern = Array.new(length)

  p_id = 0
  p_count = 2

  length.times do |i|
    if p_count % (repetitions+1) == 0 then
      p_id = (p_id + 1) % base_pattern.length
      p_count = 1
    end

    pattern[i] = base_pattern[p_id] 

    p_count += 1
  end

  return pattern
end


#def apply_fft(input)
#  output = []
#
#  i_length = input.length
#  i_length.times do |input_idx|
#    pattern = get_pattern(input_idx + 1, i_length)
#    total = 0
#    input.each_with_index do |val, idx|
#      #puts "Input length: #{input.length}, pattern length: #{pattern.length}, index: #{idx} val: #{val}"
#      this_sum = val * pattern[idx]
#      #puts "Sum is #{this_sum}"
#      total += this_sum
#    end
#    #puts "  total is #{total}"
#    output[input_idx] = total.abs % 10 # Keep only 1's digit
#  end
#  return output
#end

def apply_fft(input, offset = 0)
  output = []

  i_length = input.length

  if offset > i_length then # Work backwards calculative cumulative sum
    output[i_length-1] = input[i_length-1]

    (i_length - 2).downto(0) do |index|
      output[index] = (input[index] + output[index+1]) % 10
    end
    return output
  end

  i_length.times do |input_idx|
    total = 0
    # Step through using pattern
    add = true
    block_size = input_idx + 1 + offset
    index = input_idx
    count = 0

    if block_size > (i_length - input_idx) then
      output[input_idx] = input[input_idx..].sum % 10
      next
    end

    while index < input.length do
      if count < block_size then
        if add then
          total += input[index]
        else
          total -= input[index]
        end
        index += 1
        count += 1
      else
        index += block_size
        count = 0
        add = !add
      end
    end
    #puts "  total is #{total}"
    output[input_idx] = total.abs % 10 # Keep only 1's digit
  end
  return output
end

def first_digits(num_arr, n_digits)
  num_arr[0..(n_digits-1)].join.to_i
end

def calc_lcm(num1, num2)
  num1_inc = num1
  num2_inc = num2
  while num1 != num2 do
    if num1 < num2 then
      num1 += num1_inc
    else
      num2 += num2_inc
    end
  end
  return num1
end

def apply_fft_phases(input, num)
  output = input
  num.times do
    output = apply_fft(output.clone)
  end
  return output
end

def apply_big_fft(input, repetitions, num_phases)
  offset = input[0..6].join.to_i

  rel_offset = offset % input.length

  # Create input array starting from offset
  #puts "Input length: #{input.length * repetitions}, Offset: #{offset}"
  array_length = (input.length * repetitions) - offset
  #puts "Array length is #{array_length}"

  new_input = Array.new(array_length)

  input_id = rel_offset

  # Populate subarray from offset position
  new_input.length.times do |idx|
     new_input[idx] = input[input_id]
     input_id = (input_id + 1) % input.length
  end

  new_input.each_with_index do |val, idx|
    raise "NIL ERROR FOR VAL AT #{idx}" if val == nil
  end

  #p new_input

  output = new_input
  num_phases.times do |i|
    #puts "Phase #{i}/#{num_phases}"
    output = apply_fft(output, offset)
    #puts "#{output}"
  end

  return output
end
