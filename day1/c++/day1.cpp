#include <iostream>
#include "./day1_lib.h"
#include <fstream>

int main() {
    std::cout << "----- Part 1 -----" << std::endl;

    std::ifstream input_file("../../input/1");

    int total_fuel = 0;
    int mass = 0;

    while(input_file >> mass) {
        total_fuel += calc_fuel(mass);
    }

    std::cout << "Total fuel is " << total_fuel << std::endl;

    std::cout << "----- Part 2 -----" << std::endl;

    // Return to start of file
    input_file.clear();
    input_file.seekg(0, std::ios::beg);
    total_fuel = 0;

    while(input_file >> mass) {
        total_fuel += recursive_fuel(mass);
    }

    std::cout << "Total fuel is " << total_fuel << std::endl;
}
