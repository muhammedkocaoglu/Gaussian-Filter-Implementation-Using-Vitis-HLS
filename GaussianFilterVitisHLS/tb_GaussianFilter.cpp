#include "GaussianFilter.h"
#include <fstream>
#include <string>

int main() {

	std::cout << "Program started." << std::endl;
	bool failure = false;

	std::ifstream infile_raw_data("ImageRawArrayHex.txt");
	std::ifstream infile_golden_data("GoldenImageHexVec.txt");

	std::string data_in_string;
	std::string golden_data_string;
	ap_uint<8> data_in_hex0;
	ap_uint<8> data_in_hex1;
	ap_uint<8> data_in_hex2;
	ap_uint<8> data_in_hex3;
	ap_uint<8> data_in_hex4;
	int cntr = 0;
	while (infile_raw_data >> data_in_string)
	{

		if (cntr == 0) {
			ap_uint<8> data_in_hex00;
			sscanf(data_in_string.c_str(), "%x", &data_in_hex00);
			data_in_hex0 = data_in_hex00;
			cntr += 1;
		}
		else if (cntr == 1) {
			ap_uint<8> data_in_hex01;
			sscanf(data_in_string.c_str(), "%x", &data_in_hex01);
			data_in_hex1 = data_in_hex01;
			cntr += 1;
		}
		else if (cntr == 2) {
			ap_uint<8> data_in_hex02;
			sscanf(data_in_string.c_str(), "%x", &data_in_hex02);
			data_in_hex2 = data_in_hex02;
			cntr += 1;
		}
		else if (cntr == 3) {
			ap_uint<8> data_in_hex03;
			sscanf(data_in_string.c_str(), "%x", &data_in_hex03);
			data_in_hex3 = data_in_hex03;
			cntr += 1;
		}
		else if (cntr == 4) {
			ap_uint<8> data_in_hex04;
			ap_uint<32> data_golden;
			sscanf(data_in_string.c_str(), "%x", &data_in_hex04);
			data_in_hex4 = data_in_hex04;
			cntr = 0;
			ap_uint<32> myResult = GaussianFilter(data_in_hex0, data_in_hex1, data_in_hex2, data_in_hex3, data_in_hex4);


			infile_golden_data >> golden_data_string; // read golden data
			sscanf(golden_data_string.c_str(), "%x", &data_golden);


			if (myResult == data_golden) {
				std::cout << std::hex << data_golden << std::endl;
				std::cout << std::hex << myResult << std::endl;
			}
			else {
				std::cout << "golden data is not equal to calculated data!!" << std::endl;
				std::cout << "failure" << std::endl;
				failure = true;
				break;
			}
		}
	}


	if (failure == false)
		std::cout << "All the results matched: Successful!!!" << std::endl;


	return 0;
}
