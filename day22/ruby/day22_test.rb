require "test/unit"
require "./day22_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_to_arr
    stack = CardStack.new(10)
    assert_equal [0,1,2,3,4,5,6,7,8,9], stack.as_arr
  end

  def test_deal_new
    stack = CardStack.new(10)

    stack.deal_into_new
    assert_equal [9,8,7,6,5,4,3,2,1,0], stack.as_arr

    stack.deal_into_new
    assert_equal [0,1,2,3,4,5,6,7,8,9], stack.as_arr
  end

  def test_cut_cards
    stack = CardStack.new(10)

    stack.cut_cards(3)
    assert_equal [3,4,5,6,7,8,9,0,1,2], stack.as_arr

    stack = CardStack.new(10)
    stack.cut_cards(4)
    assert_equal [4,5,6,7,8,9,0,1,2,3], stack.as_arr

    stack = CardStack.new(10)
    stack.cut_cards(2)
    assert_equal [2,3,4,5,6,7,8,9,0,1], stack.as_arr

    stack = CardStack.new(10)

    stack.cut_cards(-4)
    assert_equal [6, 7, 8, 9, 0, 1, 2, 3, 4, 5], stack.as_arr

    stack = CardStack.new(10)
    stack.cut_cards(-5)
    assert_equal [5, 6, 7, 8, 9, 0, 1, 2, 3, 4], stack.as_arr

    stack = CardStack.new(10)
    stack.cut_cards(-3)
    assert_equal [7, 8, 9, 0, 1, 2, 3, 4, 5, 6], stack.as_arr
  end

  def test_deal_inc
    stack = CardStack.new(10)
    stack.deal_with_inc(3)
    assert_equal [0, 7, 4, 1, 8, 5, 2, 9, 6, 3], stack.as_arr

    stack = CardStack.new(10)
    stack.deal_with_inc(7)
    assert_equal [0, 3, 6, 9, 2, 5, 8, 1, 4, 7], stack.as_arr
  end

  def test_card_pos
    stack = CardStack.new(10)

    assert_equal 6, stack.get_pos_of(6)
    assert_equal 4, stack.get_pos_of(4)
  end

  def test_process_commands
    stack = CardStack.new(10)
    process_commands(stack, [
      "deal with increment 7",
      "deal into new stack",
      "deal into new stack"
    ])
    assert_equal [0, 3, 6, 9, 2, 5, 8, 1, 4, 7], stack.as_arr


    stack = CardStack.new(10)
    process_commands(stack, [
      "cut 6",
      "deal with increment 7",
      "deal into new stack",
    ])
    assert_equal [3, 0, 7, 4, 1, 8, 5, 2, 9, 6], stack.as_arr


    stack = CardStack.new(10)
    process_commands(stack, [
      "deal with increment 7",
      "deal with increment 9",
      "cut -2",
    ])
    assert_equal [6, 3, 0, 7, 4, 1, 8, 5, 2, 9], stack.as_arr, 


    stack = CardStack.new(10)
    process_commands(stack, [
      "deal into new stack",
      "cut -2",
      "deal with increment 7",
      "cut 8",
      "cut -4",
      "deal with increment 7",
      "cut 3",
      "deal with increment 9",
      "deal with increment 3",
      "cut -1"
    ])
    assert_equal [9, 2, 5, 8, 1, 4, 7, 0, 3, 6], stack.as_arr
  end
end
