#include <vector>
#include <sstream>
#include <iostream>
#include <stdexcept>
#include "./day3_lib.h"
#include <climits>

std::vector<Wire> input_to_wires(std::string input) {
	std::stringstream stream(input);
	std::string value;

	std::vector<Wire> wires;

	int cur_x = 0;
	int last_x = 0;
	int cur_y = 0; int last_y = 0;
	int end_steps = 0;
	Direction dir_enum;

	while(std::getline(stream, value, ',')){
		std::string dir = value.substr(0,1);
		int length = std::stoi(value.substr(1));
		if(dir == "U") {
			cur_y += length;
			dir_enum = Direction::vertical;
		} else if (dir == "D") {
			cur_y -= length;
			dir_enum = Direction::vertical;
		} else if (dir == "R") {
			cur_x += length;
			dir_enum = Direction::horizontal;
		} else if (dir == "L") {
			cur_x -= length;
			dir_enum = Direction::horizontal;
		} else {
			throw std::logic_error("Unrecongised direction");
		}

		end_steps += length;

		Wire wire(dir_enum, last_x, cur_x, last_y, cur_y, end_steps);

		wires.push_back(wire);

		last_x = cur_x;
		last_y = cur_y;
	}
	return wires;
}

void print_wires(std::vector<Wire> wires){
	for(Wire wire: wires){
		std::cout << "-----------------------------" << std::endl;
		std::cout << "(" << wire.start_x << ", " << wire.start_y
			<< ") (" << wire.end_x << ", " << wire.end_y << ")" << std::endl;
	}
}

bool wire_crosses_coord(int pos_x, int pos_y, const Wire &wire){
	switch(wire.dir) {
		case Direction::vertical:
			if(wire.start_x != pos_x) return false;
			if(wire.start_y <= pos_y && wire.end_y >= pos_y) return true;
			if(wire.end_y <= pos_y && wire.start_y >= pos_y) return true;
			return false;
		case Direction::horizontal:
			if(wire.start_y != pos_y) return false;
			if(wire.start_x <= pos_x && wire.end_x >= pos_x) return true;
			if(wire.end_x <= pos_y && wire.start_y >= pos_x) return true;
			return false;
			break;
	}
	return false;
}

int check_for_collision(int pos_x, int pos_y, const std::vector<Wire> &first_wires, const std::vector<Wire> &second_wires) {
	// Between horizontal first wires and vertical second wires
	for(Wire f_wire : first_wires) {
		if(f_wire.dir != Direction::horizontal || f_wire.start_y != pos_y) continue;
		if(!wire_crosses_coord(pos_x, pos_y, f_wire)) continue;

		for(Wire s_wire : second_wires){
			if(s_wire.dir != Direction::vertical || s_wire.start_x != pos_x) continue;
			// Potential collision, check
			if(wire_crosses_coord(pos_x, pos_y, s_wire)) {
				// Calculate cost
				//   c                    c
				//   | >       |   >     |
				//std::cout << "end_cost: " << f_wire.end_cost << "  end_x: " << f_wire.end_x << "  pos_x: " << pos_x << std::endl;
				int f_steps = f_wire.end_cost - abs(f_wire.end_x - pos_x);
				//std::cout << "fsteps: " << f_steps << std::endl;
				//std::cout << "end_cost: " << s_wire.end_cost << "  end_y:" << s_wire.end_y << "  pos_y: " << pos_y << std::endl;
				int s_steps = s_wire.end_cost - abs(s_wire.end_y - pos_y);
				//std::cout << "ssteps: " << s_steps << std::endl;
				return f_steps + s_steps;
			}
		}
	}
	// Between vertical first wires and horizontal second wires
	for(Wire f_wire : first_wires) {
		if(f_wire.dir != Direction::vertical || f_wire.start_x != pos_x) continue;
		if(!wire_crosses_coord(pos_x, pos_y, f_wire)) continue;

		for(Wire s_wire : second_wires){
			if(s_wire.dir != Direction::horizontal || s_wire.start_y != pos_y) continue;
			// Potential collision, check
			if(wire_crosses_coord(pos_x, pos_y, s_wire)) {
				// Calculate cost
				int f_steps = f_wire.end_cost - abs(f_wire.end_y - pos_y);
				int s_steps = s_wire.end_cost - abs(s_wire.end_x - pos_x);
				return f_steps + s_steps;
			}
		}
	}

	return 0;
}

int find_collisions(const std::vector<Wire> &first_wires, const std::vector<Wire> &second_wires, bool second_part){

	// Iterate in square around center point
	int pos_x, pos_y;
	int pos_min, pos_max;
	int inc_x, inc_y;

	int counter = 0;

	pos_x = pos_y = 1;
	inc_x = 0;
	inc_y = -1;
	pos_min = -1;
	pos_max = 1;

	int min_cost = INT_MAX;

	while(pos_max < 5000){
		if(pos_x >= pos_min && pos_x <= pos_max && pos_y >= pos_min && pos_y <= pos_max) {
			int cost = check_for_collision(pos_x, pos_y, first_wires, second_wires);
			if(cost != 0) {
				// We found one!
				std::cout << "Collision found at (" << pos_x << ", " << pos_y << ")!" << std::endl;
				if(!second_part) {
					// Return manhattan straight away
					return pos_x + pos_y;
				} else {
					// Update min cost
					if (cost < min_cost) min_cost = cost;
					std::cout << "Current min cost: " << min_cost << std::endl;
				}
			}
		} else {
			// Move back to valid space
			pos_x -= inc_x;
			pos_y -= inc_y;
			// Change direction depending on corner
			// Bottom right
			if(pos_x == pos_max && pos_y == pos_min){
				inc_y = 0;
				inc_x = -1;
			// Bottom left
			} else if (pos_x == pos_min && pos_y == pos_min){
				inc_y = 1;
				inc_x = 0;
			// Top left
			} else if (pos_x == pos_min && pos_y == pos_max){
				inc_y = 0;
				inc_x = 1;
			// Top right
			} else {
				// Move into next ring
				pos_x++;
				pos_y++;
				pos_max++;
				pos_min--;
				
				inc_x = 0;
				inc_y = -1;
			}
		}
		pos_x += inc_x;
		pos_y += inc_y;

		counter++;
	}

	if (!second_part) {
		return -1;
	} else {
		return min_cost;
	}
}
