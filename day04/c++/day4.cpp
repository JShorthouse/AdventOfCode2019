#include <iostream>
#include "./day4_lib.h"
#include <fstream>

int main() {

    int min_value = 156218;
    int max_value = 652527;

    std::cout << "----- Part 1 -----" << std::endl;

    int num_passwords = 0;

    for(int pass=min_value; pass<=max_value; pass++){
        if (valid_password(pass)) num_passwords++;
    }

    std::cout << "Total passwords " << num_passwords << std::endl;

    std::cout << "----- Part 2 -----" << std::endl;

    num_passwords = 0;

    for(int pass=min_value; pass<=max_value; pass++){
        if (valid_password_2(pass)) num_passwords++;
    }

    std::cout << "Total passwords " << num_passwords << std::endl;

    std::cout << "----- Part 2 -----" << std::endl;
}
