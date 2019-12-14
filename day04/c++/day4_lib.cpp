//#include<math.h>
//#include<algorithm>
#include<vector>

std::vector<int> int_to_vector(int number){
	std::vector<int> temp_vec;
	do {
		temp_vec.push_back(number % 10);
		number /= 10;
	} while (number > 0);

	// Reverse
	std::vector<int> vec(temp_vec.size());
	int j = 0;
	for(int i = temp_vec.size() - 1; i>= 0; i--){
		vec[j] = temp_vec[i];
		j++;
	}
	return vec;
}

bool valid_password(int password){
	std::vector<int> pass_array = int_to_vector(password);
	bool dubs = false;

	for(int i=1; i<pass_array.size(); i++){
		if (pass_array[i] == pass_array[i-1]) {
			dubs = true;
		} else if (pass_array[i] < pass_array[i-1]) {
			return false;
		}
	}
	return dubs;
}


bool valid_password_2(int password){
	std::vector<int> pass_array = int_to_vector(password);
	bool dubs = false;
	bool potential_dubs = false;
	bool last_was_dubs = false;

	for(int i=1; i<pass_array.size(); i++){
		if (pass_array[i] == pass_array[i-1]) {
			if (!last_was_dubs){
				potential_dubs = true;
			} else {
				potential_dubs = false;
			}
			last_was_dubs = true;
		} else {
			last_was_dubs = false;

			if (potential_dubs) {
				dubs = true;
			}

			if (pass_array[i] < pass_array[i-1]) {
				return false;
			}
		}
	}
	return dubs || potential_dubs;
}
