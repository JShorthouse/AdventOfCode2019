#include<math.h>
#include<algorithm>

int calc_fuel(int mass){
	return floor((mass / 3.0) - 2.0);
}

int recursive_fuel(int mass){
	int fuel_sum = 0;
	int last_mass = mass;
	int fuel = 0;

	do {
		fuel = std::max(0, calc_fuel(last_mass));
		fuel_sum += fuel;
		last_mass = fuel;
	} while (fuel != 0);

	return fuel_sum;
}
