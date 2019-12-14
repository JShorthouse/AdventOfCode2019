#include "./day3_lib.h"
#include <fstream>
#include <iostream>

int main(){
    std::cout << "----- Part 1 -----" << std::endl;

	// Read input into array
	std::ifstream input_file("../../input/3");

	std::string first_line;
	std::string second_line;

	std::getline(input_file, first_line);
	std::getline(input_file, second_line);

	std::vector<Wire> first_wires = input_to_wires(first_line);
	std::vector<Wire> second_wires = input_to_wires(second_line);

 	// TODO Sort arrays here for better performance

	int distance = find_collisions(first_wires, second_wires, false);

	std::cout << "Nearest collision is " << distance << " units away" << std::endl;


	std::cout << "----- Part 2 -----" << std::endl;

	int min_cost = find_collisions(first_wires, second_wires, true);

	std::cout << "Collision with the minimum cost has a cost of: " << min_cost << std::endl;
}

