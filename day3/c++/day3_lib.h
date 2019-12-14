#pragma once
#include <vector>
#include <string>

enum Direction {
	horizontal,
	vertical
};

struct Wire {
	Direction dir;
	int start_x, end_x, start_y, end_y;
	int end_cost;

	Wire(Direction d, int sx, int ex, int sy, int ey, int ec): dir(d), start_x(sx), end_x(ex), start_y(sy), end_y(ey), end_cost(ec) {}
};

std::vector<Wire> input_to_wires(std::string input);

void print_wires(std::vector<Wire> wires);

void print_first_wire_value(std::vector<Wire> wires);

void print_first_wire_reference(std::vector<Wire> &wires);

bool wire_crosses_coord(int pos_x, int pos_y, const Wire &wire);

int check_for_collision(int pos_x, int pos_y, const std::vector<Wire> &first_wires, const std::vector<Wire> &second_wires);

int find_collisions(const std::vector<Wire> &first_wires, const std::vector<Wire> &second_wires, bool second_part);
