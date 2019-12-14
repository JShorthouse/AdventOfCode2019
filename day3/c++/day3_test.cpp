#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "./day3_lib.h"


TEST_CASE( "Simple fuel calculation works", "[lib]" ) {
    Wire wire(Direction::horizontal, 0, 10, 2, 2, 0);
    REQUIRE( wire_crosses_coord(5, 2, wire) != 0 );
    REQUIRE( wire_crosses_coord(7, 2, wire) != 0 );
    REQUIRE( wire_crosses_coord(2, 2, wire) != 0 );
    REQUIRE( wire_crosses_coord(0, 2, wire) != 0 );
    REQUIRE( wire_crosses_coord(10, 2, wire) != 0 );
    REQUIRE( wire_crosses_coord(-1, 2, wire) == 0 );
    REQUIRE( wire_crosses_coord(11, 2, wire) == 0 );
    REQUIRE( wire_crosses_coord(6, 1, wire) == 0 );
    REQUIRE( wire_crosses_coord(5, 3, wire) == 0 );

    Wire wire2(Direction::vertical, 10, 10, -5, 6, 0);
    REQUIRE( wire_crosses_coord(5, 2, wire2) == false );
    REQUIRE( wire_crosses_coord(10, -6, wire2) == false );
    REQUIRE( wire_crosses_coord(10, 7, wire2) == false );
    REQUIRE( wire_crosses_coord(10, 5, wire2) == true );
    REQUIRE( wire_crosses_coord(10, 0, wire2) == true );
}

TEST_CASE( "Collision between sets of wires works", "[lib]" ){

    //Wire wire(Direction::horizontal, 0, 10, 2, 2);
    Wire wire2(Direction::vertical, 10, 10, -5, 6, 0);

    Wire wire3(Direction::horizontal, 0, 11, 2, 2, 0);
    //Wire wire4(Direction::vertical, 10, 10, -5, 6);

    std::vector<Wire> f_wires;
    std::vector<Wire> s_wires;

    //f_wires.push_back(wire);
    f_wires.push_back(wire2);

    s_wires.push_back(wire3);
    //s_wires.push_back(wire4);

    REQUIRE( check_for_collision(10, 2, f_wires, s_wires) != 0);
}
