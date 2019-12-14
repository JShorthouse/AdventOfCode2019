def array_from_file(filename)
  File.read(filename).chomp.split('').map(&:to_i)
end

def load_image(width, height, data)
  idx = 0
  lay = 0
  output = []
  while idx < data.length
    layer = []
    height.times do |h|
      row = []
      width.times do |w|
        row[w] = data[idx]
        idx += 1
      end
      layer[h] = row
    end
    output[lay] = layer
    lay += 1
  end
  output
end

def count_in_layer(target, layer)
  total_count = 0
  layer.each do |row|
    total_count += row.count(target)
  end
  return total_count
end

def squash_image(layers)
  # Make output array with size of image, filled with transparent pixels
  output = Array.new(layers[0].length){Array.new(layers[0][0].length, 2)}
  layers.each do |layer|
    layer.each_with_index do |row, y|
      row.each_with_index do |pixel, x|
        if output[y][x] != 2 then next end
        output[y][x] = pixel
      end
    end
  end
  return output
end

def render_image(img)
  img.each do |row|
    row.each do |pixel|
      print( pixel == 1 ? "█" : " " )
    end
    print("\n")
  end
end
