require "test/unit"
require "./day8_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_count_in_layer
    lay = [[0,0,0,1], [0,1,0,0], [0,5,1,6]]
    assert_equal 7, count_in_layer(0, lay)
    assert_equal 3, count_in_layer(1, lay)
    assert_equal 0, count_in_layer(3, lay)
    assert_equal 1, count_in_layer(5, lay)
  end

  def test_load_image
    img_data = 123456789012.to_s.chomp.split('').map(&:to_i)
    img = load_image(3,2, img_data)
    assert_equal 2, img.length       # 2 layers
    assert_equal 2, img[0].length    # 2 tall
    assert_equal 3, img[0][0].length # 3 wide

    expected = [[[1,2,3],[4,5,6]], [[7,8,9],[0,1,2]]]
    assert_equal expected, img

    img.each do |lay|
      p lay
      puts count_in_layer(0, lay)
    end
  end

  def test_squash_image
    img_data = "0222112222120000".chomp.split('').map(&:to_i)
    puts "Image data:"
    p img_data
    img = load_image(2,2, img_data)
    assert_equal [[0,1],[1,0]], squash_image(img)
  end
end
