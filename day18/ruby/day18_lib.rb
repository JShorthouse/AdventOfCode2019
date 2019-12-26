class MazePath
  attr_accessor :distance, :keys_needed, :key
  def initialize(key, dist, keys_needed)
    @key = key
    @distance = dist
    @keys_needed = keys_needed
  end

  def to_s
    return "#{distance} -> #{key}, k:#{keys_needed}"
  end

  def inspect
    to_s
  end
end

Position = Struct.new(:x, :y)

class MazeObject
  attr_accessor :paths, :pos
  def initialize(x, y)
    @paths = []
    @pos = Position.new(x, y)
  end

  def to_s
    return "pos: (#{@pos.x}, #{@pos.y})\npaths: #{paths}\n"
  end

  def inspect
    to_s
  end
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
      return false
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


class PQueueNode
  attr_accessor :priority, :value, :index
  def initialize(priority, value)
    @priority = priority
    @value = value
    @index
  end
end

class MinPQueue
  def initialize
    @heap = Array.new(50000)
    @h_size = 0
  end
  def parent_idx(idx)
    return idx / 2
  end
  def left_idx(idx)
    return idx * 2 
  end
  def right_idx(idx)
    return idx * 2 + 1
  end

  def min_heapify(idx)
    l_idx = left_idx(idx) - 1
    r_idx = right_idx(idx) - 1
    idx = idx - 1

    smallest_idx = idx
    if l_idx < @h_size && @heap[l_idx].priority < @heap[idx].priority then
      smallest_idx = l_idx
    end
    if r_idx < @h_size && @heap[r_idx].priority < @heap[smallest_idx].priority then
      smallest_idx = r_idx
    end
    if smallest_idx != idx then
      # Swap indexes
      @heap[idx].index = smallest_idx + 1
      @heap[smallest_idx].index = idx + 1

      # Actually swap nodes
      temp = @heap[idx]
      @heap[idx] = @heap[smallest_idx]
      @heap[smallest_idx] = temp

      min_heapify(smallest_idx + 1)
    end
  end

  def decrease_key(idx, new_key)
    if new_key > @heap[idx-1].priority then
      raise "Error - New key is larger than current key"
    end
    @heap[idx-1].priority = new_key

    while idx > 1 && @heap[parent_idx(idx) -1].priority > new_key do
      parent = parent_idx(idx)

      # Swap indexes
      @heap[idx-1].index = parent
      @heap[parent - 1].index = idx

      # Actually swap nodes
      temp = @heap[idx-1]
      @heap[idx-1] = @heap[parent - 1]
      @heap[parent - 1] = temp

      idx = parent
    end
  end

  def check_node_indexes
   # puts "Putting indexes"
   # for i in 0..@h_size-1 do
   #   puts "#{@heap[i].index} #{@heap[i]}"
   # end
   # puts "Done"
    for i in 0..@h_size-1 do
      if @heap[i].index != i + 1 then
        raise "Index mismatch: expected #{i + 1}, was #{@heap[i].index}"
      end
    end
  end

  def insert(priority, value)
    node = PQueueNode.new(Float::INFINITY, value)
    @heap[@h_size] = node
    node.index = @h_size + 1
    @h_size += 1
    decrease_key(@h_size, priority)

    return node
  end

  def extract_min
    if @h_size < 1 then raise "Heap underflow" end

    min_node = @heap[0]

    @heap[0] = @heap[@h_size - 1]
    @heap[0].index = 1
    @h_size -= 1
    min_heapify(1)

    return min_node.value, min_node.priority
  end

  def length
    @h_size
  end
end

def process_input(filename)
  output_arr = []
  File.open(filename).each_line do |line|
    output_arr.push(line.chomp.split(''))
  end
  return output_arr
end

def find_maze_objects(maze)
  maze_objects = {}
  maze.each_with_index do |row, y|
    row.each_with_index do |elem, x|
      #if elem =~ /[A-Za-z]/ || elem == "@" then
      if elem =~ /[a-z]/ || elem == "@" then
        maze_objects[elem] = MazeObject.new(x, y)
      end
    end
  end

  return maze_objects
end


$directions = [[1,0], [0,1], [-1,0], [0,-1]]

def calculate_paths(maze, maze_objects)
  # Perform bfs
  maze_obj_map = Array.new(maze.length){ Array.new(maze[0].length, nil) }

  maze_objects.each do |name, obj|
    maze_obj_map[obj.pos.y][obj.pos.x] = name
  end

  maze_objects.each do |start_name, start_obj|
    # Only process keys and starting position
    if start_name !~ /[a-z]/ && start_name != "@" then next end

    depth_map = Array.new(maze.length){ Array.new(maze[0].length, nil) }
    color_map = Array.new(maze.length){ Array.new(maze[0].length, :white) }
    key_map = Array.new(maze.length){ Array.new(maze[0].length, nil) }

    obj_queue = Queue.new

    depth_map[start_obj.pos.y][start_obj.pos.x] = 0
    color_map[start_obj.pos.y][start_obj.pos.x] = :gray
    key_map[start_obj.pos.y][start_obj.pos.x] = 0

    obj_queue.enqueue(Position.new(start_obj.pos.x, start_obj.pos.y))

    key_sets = [[]]
    next_key_id = 1

    while current_pos = obj_queue.dequeue do
      current_pos = current_pos.value
      $directions.each do |dir|
        pos_x = current_pos.x + dir[0]
        pos_y = current_pos.y + dir[1]

        if maze[pos_y][pos_x] == "#" then next end

        if color_map[pos_y][pos_x] == :white then
          color_map[pos_y][pos_x] = :gray
          depth = depth_map[current_pos.y][current_pos.x] + 1
          depth_map[pos_y][pos_x] = depth


          cur_key_id = key_map[current_pos.y][current_pos.x]
          # If doors found, create new key set
          if maze[pos_y][pos_x] =~ /[A-Z]/ then
            old_key_id = cur_key_id
            cur_key_id = next_key_id
            next_key_id += 1
            key_sets[cur_key_id] = (key_sets[old_key_id] + [ maze[pos_y][pos_x].downcase ]).uniq
          end

          if maze[pos_y][pos_x] =~ /[a-z]/ then
            # Create edge
            path = MazePath.new(maze[pos_y][pos_x], depth, key_sets[cur_key_id])
            start_obj.paths.push(path)

            # Add this key as a requirement for this path
            old_key_id = cur_key_id
            cur_key_id = next_key_id
            next_key_id += 1
            key_sets[cur_key_id] = (key_sets[old_key_id] + [ maze[pos_y][pos_x].downcase ]).uniq
          end
          key_map[pos_y][pos_x] = cur_key_id

          obj_queue.enqueue(Position.new(pos_x, pos_y))
        end

        color_map[current_pos.y][current_pos.x] = :black
        #render_bfs_map(maze, color_map, depth_map)
      end
    end
  end
end

def has_needed_keys(keys, needed)
  needed.each do |n_key|
    if !keys.include?(n_key) then
      return false
    end
  end
  return true
end

def calculate_shortest_path(maze_objects)
  # Use modified version of Dijstra's algorithm to find shortest path
  # Nodes are keys + set all possible keys before
  # i.e. [a, [abc]] is the same node as [a, [bca]]
  
  visited_nodes = {} # { key => { key_combination => minimum_steps }}

  total_keys = 0
  maze_objects.each do |key, val|
    if key =~ /[a-z]/ then
      total_keys += 1
      visited_nodes[key] = {}
    end
  end

  visited_nodes["@"] = {} # add start to make dealing with inital edge case easier
  visited_nodes["@"][[]] = []
  visited_nodes["@"][[]][0] = 0

  edge_nodes = MinPQueue.new # [min_distance] [key, key_combination]

  edge_nodes.insert(0, ["@", []])

  goal_paths = []
  count = 0

  while edge_nodes.length > 0 do
    count += 1

    min_node, cur_distance = edge_nodes.extract_min
    #puts "Min node is"
    #p min_node

    cur_key = min_node[0]
    cur_combo = min_node[1]

    cur_obj = maze_objects[cur_key]

    # Process all paths from this node that we have the needed keys for and that
    # are not already included in the current key combo
    cur_obj.paths.each do |path|
      if !cur_combo.include?(path.key) &&
         has_needed_keys(cur_combo, path.keys_needed) then

        new_distance = cur_distance + path.distance
        path_key = path.key
        new_combo = (cur_combo + [ path_key]).sort

        if !visited_nodes[path_key][new_combo] then
          visited_nodes[path_key][new_combo] = []
        end

        # Find previous shortest path to this node
        dist_from_before = visited_nodes[path_key][new_combo][0]
        node_from_before = visited_nodes[path_key][new_combo][1]

        # Skip if we have found a shorter path to this node before
        if dist_from_before && dist_from_before < new_distance then
          next
        end

        visited_nodes[path_key][new_combo][0] = new_distance

        # Update / create queue node for this edge
        if node_from_before then
           edge_nodes.decrease_key(node_from_before.index, new_distance)
        else
          node = edge_nodes.insert(new_distance, [path_key, new_combo])
          visited_nodes[path_key][new_combo][1] = node
        end

        # If we have reached the goal state, add to list
        if new_combo.length == total_keys then
          goal_paths.push(new_distance)
        end
      end
    end
  end

  min_idx = nil
  min_distance = 2 ** 32
  goal_paths.each_with_index do |dist, idx|
    #puts "dist: #{dist}, idx #{idx}"
    if dist < min_distance then
      min_distance = dist
      min_idx = idx
    end
  end

  return goal_paths[min_idx]
end



def render_bfs_map(map_clone, color_map, depth_map)
  #map_clone = Marshal.load(Marshal.dump(map))

  map_clone.each_with_index do |row, y|
    row.each_with_index do |elem, x|
      if depth = depth_map[y][x] then

        depth = '%-3s' % depth.to_s

        color = color_map[y][x]
        if color == nil then throw "Invalid color" end

        if color == :black then print "\e[31m#{depth}\e[0m" end
        if color == :gray  then print "\e[33m#{depth}\e[0m" end
        if color == :white then print "\e[32m#{depth}\e[0m" end
      elsif elem == "." then
        print "   "
      else
        print elem * 3
      end
    end
    print "\n"
  end

  sleep(0.06)
end

