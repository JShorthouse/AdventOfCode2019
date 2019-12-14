#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "./day4_lib.h"

TEST_CASE( "Int to vector works", "[lib]" ) {
    REQUIRE( int_to_vector(1234) == std::vector<int>{1,2,3,4} );
    REQUIRE( int_to_vector(158912) == std::vector<int>{1,5,8,9,1,2} );
}

TEST_CASE( "Valid password function works", "[simple]" ){
    REQUIRE( true  == valid_password(111111) );
    REQUIRE( false == valid_password(223450) );
    REQUIRE( false == valid_password(123789) );
    REQUIRE( true  == valid_password(556789) );
    REQUIRE( false == valid_password(554789) );
}

TEST_CASE( "Valid password 2 function works", "[complex]" ){
    REQUIRE( false == valid_password_2(111111) );
    REQUIRE( true  == valid_password_2(556789) );
    REQUIRE( false == valid_password_2(223450) );
    REQUIRE( false == valid_password_2(555789) );
    REQUIRE( true  == valid_password_2(112233) );
    REQUIRE( false == valid_password_2(123444) );
    REQUIRE( true  == valid_password_2(111122) );
    REQUIRE( true  == valid_password_2(112222) );
}
