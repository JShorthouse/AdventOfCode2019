def process_input(filename)
  output_arr = []
  File.open(filename).each_line do |line|
    output_arr.push(line.chomp.split(''))
  end
  return output_arr
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

class Portal
  attr_accessor :x, :y, :name, :edges
  def initialize
    @edges = []
  end

  def to_s
    return_string = @name + " "
    edges.each do |edge|
      return_string += "[ #{edge.node.name}, #{edge.distance} ] "
    end
    return return_string
  end
end

def clone_portal(portal)
  new_portal = portal.clone
  new_portal.edges = portal.edges.clone
  return new_portal
end

Edge = Struct.new(:distance, :node)

Position = Struct.new(:x, :y)

def find_portals(arr)
  portals = []
  arr.each_with_index do |row, y|
    row.each_with_index do |elem, x|
      if elem =~ /[A-Z]/ 

        portal = nil

        # To avoid duplicates only proceed if element is top or left of a portal
        if x + 1 < arr[0].length && arr[y][x+1] =~ /[A-Z]/ then # Horizontal
          portal = Portal.new
          portal.name = arr[y][x] + arr[y][x+1]
          portal.y = y
          # Check if path is right or left and set x accordingly
          if x > 0 && arr[y][x-1] == "." then
            portal.x = x - 1
          else
            portal.x = x + 2
          end

        elsif y + 1 < arr.length && arr[y+1][x] =~ /[A-Z]/ # Vertical
          portal = Portal.new
          portal.name = arr[y][x] + arr[y+1][x]
          portal.x = x

          # Check if path is up or down and set x accordingly
          if y > 0 && arr[y-1][x] == "." then
            portal.y = y - 1
          else
            portal.y = y + 2
          end
        else 
          next
        end

        portals.push(portal)
      end
    end
  end
  return portals
end

$directions = [[1,0], [0,1], [-1,0], [0,-1]]

def build_graph(map, portals)
  portal_map = Array.new(map.length){ Array.new(map[0].length, nil) }

  portals.each do |portal|
    portal_map[portal.y][portal.x] = portal
  end

  # Perform DFS from each portal
  portals.each do |start_portal|
    #puts "Performing DFS from portal #{start_portal}"
    depth_map = Array.new(map.length){ Array.new(map[0].length, nil) }
    color_map = Array.new(map.length){ Array.new(map[0].length, :white) }

    node_queue = Queue.new

    depth_map[start_portal.y][start_portal.x] = 0
    color_map[start_portal.y][start_portal.x] = :gray

    node_queue.enqueue(Position.new(start_portal.x, start_portal.y))

    while current_pos = node_queue.dequeue do
      current_pos = current_pos.value
      $directions.each do |dir|
        pos_x = current_pos.x + dir[0]
        pos_y = current_pos.y + dir[1]

        if map[pos_y][pos_x] != "." then next end

        if color_map[pos_y][pos_x] == :white then
          color_map[pos_y][pos_x] = :gray
          depth = depth_map[current_pos.y][current_pos.x] + 1
          depth_map[pos_y][pos_x] = depth

          if found_portal = portal_map[pos_y][pos_x] then
            # Create edge
            start_portal.edges.push(Edge.new(depth, found_portal))
          end

          node_queue.enqueue(Position.new(pos_x, pos_y))
        end

        color_map[current_pos.y][current_pos.x] = :black

        #render_dfs_map(map, color_map, depth_map)
      end
    end
  end
  return portals
end

def link_portals(portals)
  first_portals = {}

  # Rename first portal found to #{name}a and second to #{name}b, then create
  # link of 1 step between them
  
  portals.each do |portal|
    if portal.name == "AA" || portal.name == "BB" then next end

    if first_portal = first_portals[portal.name] then
      first_portal.name += "a"
      portal.name += "b"
      first_portal.edges.push(Edge.new(1, portal))
      portal.edges.push(Edge.new(1, first_portal))
    else
      first_portals[portal.name] = portal
    end
  end
  return portals
end

def calculate_shortest_path(portals)

  nodes_by_name = {}

  # Dijkstra's algorithm
  min_distances = {}

  node_queue = []

  portals.each do |portal|
    nodes_by_name[portal.name] = portal
    distance = 2**32
    if portal.name == "AA" then distance = 0 end
    min_distances[portal.name] = distance
    node_queue.push(portal.name)
  end


  while node_queue.length > 0 do
    # Extract mimimum distance node
    min_d = 2**32
    min_name = nil
    node_queue.each do |node_name|
      distance = min_distances[node_name]
      if distance <= min_d then
        min_d = distance
        min_name = node_name
      end
    end

    node_queue.delete(min_name)
    cur_node = nodes_by_name[min_name]

    #puts "Iterating for #{min_name}"
    #puts "Queue contents is:"
    #p node_queue
    #puts "Min distances is"
    #p min_distances
    #puts ""

    # Recalculate min distances for all adjacent nodes
    cur_node_distance = min_distances[cur_node.name]
    cur_node.edges.each do |edge|
      distance_from_this = cur_node_distance + edge.distance

      if distance_from_this < min_distances[edge.node.name] then
        min_distances[edge.node.name] = distance_from_this
      end
    end
  end

  # Return distance to portal
  return min_distances["ZZ"]
end

def find_length_to_exit(map)
  portals = find_portals(map)
  portals = build_graph(map, portals)
  link_portals(portals)

  return calculate_shortest_path(portals)
end

def render_dfs_map(map_clone, color_map, depth_map)
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

def render_map(arr, portals)
  arr_clone = Marshal.load(Marshal.dump(arr))

  portals.each do |portal|
    arr_clone[portal.y][portal.x] = 1
    arr_clone[portal.y][portal.x+1] = portal.name
  end

  arr_clone.each do |row|
    row.each do |elem|
      if elem == 1 then
        print "\e[35mP\e[0m"
      else
        print elem
      end
    end
    print "\n"
  end
end
