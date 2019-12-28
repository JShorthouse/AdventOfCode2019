def process_input(filename)
  output_arr = []
  File.open(filename).each_line do |line|
    output_arr.push(line.chomp.split(''))
  end
  return output_arr
end


$dirs = [[1,0], [0,1], [-1,0], [0,-1]]

def simulate_grid(grid)
  new_grid = Array.new(grid.length) { Array.new(grid[0].length) }
  grid.each_with_index do |row, y|
    row.each_with_index do |elem, x|
      adj_count = 0
      $dirs.each do |dir|
        new_y = y + dir[0]
        new_x = x + dir[1]

        if new_y >= 0 && new_y < grid.length && new_x >= 0 && new_x < grid[0].length then
          if grid[new_y][new_x] == "#" then
            adj_count += 1
          end
        end
      end

      if elem == "#" && adj_count == 1 then
        new_grid[y][x] = "#"
      elsif (elem == ".") && (adj_count == 1 || adj_count == 2) then
        new_grid[y][x] = "#"
      else
        new_grid[y][x] = "."
      end
    end
  end
  return new_grid
end

def get_recurs_adjacent(level, y, x)
  adj_list = [] #[ level, y, x]

  mid_x = 2
  mid_y = 2
  grid_dim = 5

  $dirs.each do |dir|
    new_y = y + dir[0]
    new_x = x + dir[1]

    if new_y == mid_y && new_x == mid_x then
      if dir == [1,0] then # down inner
        grid_dim.times do |i|
          adj_list.push([level-1, 0, i]) # Add top row of lower level
        end
      elsif dir == [-1,0] then # up inner
        grid_dim.times do |i|
          adj_list.push([level-1, grid_dim-1, i]) # Add bottom row of lower level
        end
      elsif dir == [0, 1] then # right inner
        grid_dim.times do |i|
          adj_list.push([level-1, i, 0]) # Add left row of inner level
        end
      elsif dir == [0,-1] then # left inner
        grid_dim.times do |i|
          adj_list.push([level-1, i, grid_dim-1]) # Add left row of inner level
        end
      end
    elsif new_y == grid_dim then # down outer
      adj_list.push([level+1, mid_y + 1, mid_x])
    elsif new_y == -1 then # up outer
      adj_list.push([level+1, mid_y - 1, mid_x])
    elsif new_x == grid_dim then # right outer
      adj_list.push([level+1, mid_y, mid_x + 1])
    elsif new_x == -1 then # left outer
      adj_list.push([level+1, mid_y, mid_x - 1])
    else
      # On current level
      adj_list.push([level, new_y, new_x])
    end
  end

  return adj_list
end

def gen_recursive_grid(starting_map, size)
  arr_length = 1 + size * 2
  grids = Array.new(arr_length) { 
    Array.new(starting_map.length) { Array.new(starting_map[0].length) {"."} }
  }

  # Set middle of grid to starting map
  grids[size + 1] = starting_map

  return grids
end

def print_grid(grid)
  grid.each_with_index do |row, y|
    row.each_with_index do |elem, x|
      print elem
    end
  print "\n"
  end
end

def simulate_recursive_grids(grids)
  new_grids = Array.new(grids.length) { 
    Array.new(grids[0].length) { Array.new(grids[0][0].length) }
  }

  grids.each_with_index do |grid, level|
    grid.each_with_index do |row, y|
      row.each_with_index do |elem, x|
        if x == 2 && y == 2 then 
          new_grids[level][y][x] = "?"
          next 
        end # Skip middle section

        adj_count = 0
        adj = get_recurs_adjacent(level, y, x)
        adj.each do |adj_level, adj_y, adj_x|

          if adj_level < 0 || adj_level >= grids.length then
            next
          end

          #puts "adj_l: #{adj_level}, adj_y: #{adj_y}, adj_x #{adj_x}"
          if grids[adj_level][adj_y][adj_x] == "#" then
            adj_count += 1
            #puts "On level #{level} found adj at #{adj_level}"
          end
        end

        if elem == "#" && adj_count == 1 then
          new_grids[level][y][x] = "#"
        elsif (elem == ".") && (adj_count == 1 || adj_count == 2) then
          new_grids[level][y][x] = "#"
        else
          new_grids[level][y][x] = "."
        end
      end
    end
  end

  return new_grids
end

def get_grid_checksum(grid)
  multip = 1
  checksum = 0
  grid.each do |row|
    row.each do |elem|
      if elem == "#" then
        checksum += multip
      end
      multip *= 2
    end
  end
  return checksum
end

def count_total_bugs(grids)
  total_bugs = 0
  grids.each_with_index do |grid, level|
    grid.each_with_index do |row, y|
      row.each_with_index do |elem, x|
        if elem == "#" then
          total_bugs += 1
        end
      end
    end
  end
  return total_bugs
end

def run_until_duplicate(grid)
  prev_checksums = []

  loop do
    grid = simulate_grid( grid )

    checksum = get_grid_checksum( grid )

    if prev_checksums.include?(checksum) then
      return checksum
    else
      prev_checksums.push(checksum)
    end
  end
end

def run_recursive(grids, steps)
  steps.times do |step|
    grids = simulate_recursive_grids(grids)
  end
  return grids
end
