#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "./day1_lib.h"

TEST_CASE( "Simple fuel calculation works", "[simple]" ) {
    REQUIRE( calc_fuel(12) == 2 );
    REQUIRE( calc_fuel(14) == 2 );
    REQUIRE( calc_fuel(1969) == 654 );
    REQUIRE( calc_fuel(100756) == 33583 );
}

TEST_CASE( "Recursive fuel calculation works", "[recursive]" ) {
    REQUIRE( recursive_fuel(14) == 2 );
    REQUIRE( recursive_fuel(1969) == 966 );
    REQUIRE( recursive_fuel(100756) == 50346 );
}
