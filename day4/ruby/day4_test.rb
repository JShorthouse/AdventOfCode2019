require "test/unit"
require "./day4_lib.rb"

class LibTests < Test::Unit::TestCase
  def test_password_checker
    assert_equal true,  valid_password(111111)
    assert_equal false, valid_password(223450)
    assert_equal false, valid_password(123789)
    assert_equal true,  valid_password(556789)
    assert_equal false, valid_password(554789)
  end

  def test_password_checker_2
    assert_equal false, valid_password_2(111111)
    assert_equal true,  valid_password_2(556789)
    assert_equal false, valid_password_2(223450)
    assert_equal false, valid_password_2(555789)
    assert_equal true,  valid_password_2(112233)
    assert_equal false, valid_password_2(123444)
    assert_equal true,  valid_password_2(111122)
    assert_equal true,  valid_password_2(112222)
  end
end

