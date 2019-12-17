require "test/unit"
require "./day16_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_get_pattern
    assert_equal [1,0,-1,0], get_pattern(1, 4)
    assert_equal [1,0], get_pattern(1, 2)
    assert_equal [1,0,-1,0,1,0,-1,0], get_pattern(1, 8)
    assert_equal [0,1,1,0,0,-1,-1,0], get_pattern(2, 8)
    assert_equal [0,0,1,1,1,0,0,0], get_pattern(3, 8)
    assert_equal [0,1,1,0], get_pattern(2, 4)
  end

  def test_first_digits
    assert_equal 12, first_digits([1,2,3,4,5,6,7,8,9,0], 2)
    assert_equal 123456, first_digits([1,2,3,4,5,6,7,8,9,0], 6)
    assert_equal 12345678, first_digits([1,2,3,4,5,6,7,8,9,0], 8)
  end

  def test_apply_fft
    assert_equal 1029498 , first_digits( apply_fft_phases(i_to_arr(12345678), 4), 8)
    assert_equal 24176176, first_digits( apply_fft_phases(i_to_arr(80871224585914546619083218645595), 100) , 8)
    assert_equal 73745418, first_digits( apply_fft_phases(i_to_arr(19617804207202209144916044189917), 100) , 8)
    assert_equal 52432133, first_digits( apply_fft_phases(i_to_arr(69317163492948606335995924319873), 100) , 8)
  end

  def test_apply_fft_offset
    assert_equal 6158, first_digits( apply_fft(i_to_arr(5678), 4), 4)
    assert_equal 438, first_digits( apply_fft(i_to_arr(6158), 4), 4)
  end

  def test_apply_large
    input = "03036732577212944063491565474664".split('').map(&:to_i)
    output = apply_big_fft(input, 10000, 100)
    assert_equal 84462026, first_digits( output , 8)

    input = "02935109699940807407585447034323".split('').map(&:to_i)
    output = apply_big_fft(input, 10000, 100)
    assert_equal 78725270, first_digits( output, 8)

    input = "03081770884921959731165446850517".split('').map(&:to_i)
    output = apply_big_fft(input, 10000, 100)
    assert_equal 53553731, first_digits( output, 8)
  end
end

