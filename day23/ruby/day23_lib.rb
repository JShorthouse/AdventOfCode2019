@output = ""

def read_to_array(file)
  File.read(file).split(',').map(&:strip).map(&:to_i)
end

class QueueNode
  attr_accessor :value, :next, :priority
  def initialize(value)
    @value = value
  end
end

class Queue
  def initialize
    @head = nil
    @tail = nil
  def enqueue(value)
    node = QueueNode.new(value)
    if @tail then
      @tail.next = node
      @tail = node
    else
      @head = node
      @tail = node
    end
  end
  def dequeue
    if @head == nil then
      return nil
    end
    if @head == @tail then
      node = @head
      @head = nil
      @tail = nil
      return node
    else
      node = @head
      @head = node.next
      return node
    end
  end
  end
end

class IntComp
  def initialize(program, non_interactive = false)
    @output = ""
    @halted = false
    @program = program
    @non_interactive = non_interactive

    @counter = 0
    @rel_base = 0
    @status = nil
    @increment = 0

    @break_counter = 11
    @input_queue = Queue.new
  end

  def add_input(input)
    @input_queue.enqueue(input)
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
    @status = nil
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
        q_node = @input_queue.dequeue

        if q_node then
          #puts "Setting input to #{q_node.value}"
          input = q_node.value 
        else
          input = -1
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
    @counter += @increment
    while process_command(@counter) do
      @counter += @increment
    end
    return @status, @output
  end

  def run_single_step
    process_command(@counter)
    @counter += @increment
    return @status, @output
  end
end

def simulate_network(program, num_nodes, target)
  nodes = Array.new(num_nodes)

  packet_table = Array.new(num_nodes) { Array.new(3) } # [addr, x, y]
  packet_idx = Array.new(num_nodes) { 0 } # current index in packet table

  nat_table = Array.new(2)
  last_nat_y = nil

  num_nodes.times do |idx|
    node = IntComp.new(program.clone, true)
    node.add_input(idx)
    nodes[idx] = node
  end

  running = true
  idle_count = 0

  while running do
    idle = true
    nodes.each_with_index do |node, idx|
      status, output = node.run_single_step
      if status == :output then
        idle = false
        packet_table[idx][packet_idx[idx]] = output
        if packet_idx[idx] == 2 then
          # Send packet
          dest = packet_table[idx][0]

          puts "From #{idx}: #{packet_table[idx]}"
          #p packet_table[idx]

          if dest == target then
            p packet_table[idx]
            return packet_table[idx][2]
          end

          if !packet_table[idx][1] || !packet_table[idx][2] then
            raise "Nil values in packet"
          end

          if dest < num_nodes then
            dest_node = nodes[dest]

            dest_node.add_input packet_table[idx][1]
            dest_node.add_input packet_table[idx][2]
          end

          if dest == 255 then
            nat_table[0] = packet_table[idx][1]
            nat_table[1] = packet_table[idx][2]
          end

          packet_idx[idx] = 0
          packet_table[idx].map! { nil }
        else
          packet_idx[idx] += 1
        end
      elsif status == :halted then
        running = false
      elsif status != nil then
        raise "Unexpected status #{status}"
      end
    end

    if idle then
      idle_count += 1

      if idle_count == 1000 then
        puts "----------- NAT ------------------"
        p nat_table
        puts "--------- NAT END ----------------"

        # Send NAT packet
        nat_table.each do |value|
          nodes[0].add_input value
        end

        if last_nat_y == nat_table[1] then
          return nat_table[1]
        else
          last_nat_y = nat_table[1]
        end

        idle_count = 0
      end
    else
      idle_count = 0
    end
  end
end
