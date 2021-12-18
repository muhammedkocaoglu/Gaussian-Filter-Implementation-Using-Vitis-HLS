#include "GaussianFilter.h"


ap_uint<32> GaussianFilter(
		ap_uint<8> data_in_0,
		ap_uint<8> data_in_1,
		ap_uint<8> data_in_2,
		ap_uint<8> data_in_3,
		ap_uint<8> data_in_4) {
#pragma HLS INTERFACE ap_none port=data_in_3
#pragma HLS INTERFACE ap_none port=data_in_4
#pragma HLS INTERFACE ap_none port=data_in_2
#pragma HLS INTERFACE ap_none port=data_in_1
#pragma HLS INTERFACE ap_none port=data_in_0

	static ap_uint<8> data_in_array[5][5] = {
			{0x00, 0x00, 0x00, 0x00, 0x00},
			{0x00, 0x00, 0x00, 0x00, 0x00},
			{0x00, 0x00, 0x00, 0x00, 0x00},
			{0x00, 0x00, 0x00, 0x00, 0x00},
			{0x00, 0x00, 0x00, 0x00, 0x00}
	};

	for (int i = 0; i < 5; i++) {
#pragma HLS unroll
		for (int j = 4; j > 0; j--) {
#pragma HLS unroll
			data_in_array[i][j] = data_in_array[i][j-1];
		}
	}


	data_in_array[0][0] = data_in_0;
	data_in_array[1][0] = data_in_1;
	data_in_array[2][0] = data_in_2;
	data_in_array[3][0] = data_in_3;
	data_in_array[4][0] = data_in_4;



	ap_uint<32> MulRes[5][5];
	for (int i = 0; i < 5; i++) {
#pragma HLS unroll
		for (int j = 0; j < 5; j++) {
#pragma HLS unroll
			MulRes[i][j] = data_in_array[i][j] * GaussianCoeffs[i][j];
		}
	}


	ap_uint<32> AddRes_Stage1[2][5];
	// addition stage 1
	for (int i = 0; i < 2; i++) {
#pragma HLS unroll
		for (int j = 0; j < 5; j++) {
#pragma HLS unroll
			AddRes_Stage1[i][j] = MulRes[i][j] + MulRes[3-i][j];
		}
	}

	// addition stage 2
	ap_uint<32> AddRes_Stage2[1][5];
	for (int i = 0; i < 5; i++) {
#pragma HLS unroll
		AddRes_Stage2[0][i] = AddRes_Stage1[0][i] + AddRes_Stage1[1][i];
	}

	// addition stage 3
	ap_uint<32> AddRes_Stage3[1][5];
	for (int i = 0; i < 5; i++) {
#pragma HLS unroll
		AddRes_Stage3[0][i] = AddRes_Stage2[0][i] + MulRes[4][i];
	}


	///////
	// add stage 4
	ap_uint<32> AddRes_Stage4[2];
	for (int i = 0; i < 2; i++) {
#pragma HLS unroll
		AddRes_Stage4[i] = AddRes_Stage3[0][i] + AddRes_Stage3[0][3-i];
	}


	// add stage 5
	ap_uint<32> AddRes_Stage5[1];
	AddRes_Stage5[0] = AddRes_Stage4[0] + AddRes_Stage4[1];


	// add stage 6
	ap_uint<32> res;
	res = AddRes_Stage3[0][4] + AddRes_Stage5[0];

	return res;
}
