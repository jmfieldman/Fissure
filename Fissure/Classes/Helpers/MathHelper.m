//
//  MathHelper.m
//
//  Created by Jason Fieldman on 9/4/10.
//  Copyright 2010 Jason Fieldman. All rights reserved.
//

#import "MathHelper.h"
#import <math.h>

void InitializeHypHelper(void);
void InitializeAngleHelper(void);
void InitializeArctanHelper(void);
void InitializeArcsinHelper(void);
void InitializeRNGHelper(void);

float  SQRT_3_F = 0;
double SQRT_3_D = 0;


/* Hyp Helper */
float hyp_helper[HYP_HELPER_SZ];
void InitializeHypHelper() {
	for (int i = 0; i < HYP_HELPER_MAX; i++) {
		for (int j = 0; j < HYP_HELPER_MAX; j++) {
			HYP_OF(i, j) = (float)sqrt(i * i + j * j);
		}
	}
}

/* Angle helper */
float deg_to_rad_array[DEGREES_NUM];
float sin_of_deg_array[DEGREES_NUM];
float cos_of_deg_array[DEGREES_NUM];
void InitializeAngleHelper() {
	for (int d = 0; d < DEGREES_NUM; d++) {
		_DEG2RAD(d) = d * (M_PI / 180.0);
		_COS_DEG(d) = (float)cos(_DEG2RAD(d));
		_SIN_DEG(d) = (float)sin(_DEG2RAD(d));
	}
}

/* arctan helper */
int atan_helper[ATAN_HELPER_SZ];

void InitializeArctanHelper() {
	for (int i = 0; i < ATAN_HELPER_MAX; i++) {
		for (int j = 0; j < ATAN_HELPER_MAX; j++) {
			int x = i - ATAN_HELPER_HALF;
			int y = j - ATAN_HELPER_HALF;
			if (x == 0) {
				if (y > 0) ATAN_OF(x, y) = 90;
				else ATAN_OF(x, y) = 270;
				continue;
			}
			if (y == 0) {
				if (x > 0) ATAN_OF(x, y) = 0;
				else ATAN_OF(x, y) = 180;
				continue;
			}
			//float slope = (float)y / (float)x;
			float atan_result = atan2(y, x);
			int degs = (int)(atan_result * (180.0 / M_PI));
			//if (x < 0) {
			//	degs += 180;
			//}
			degs = (degs + 720) % 360;
			ATAN_OF(x, y) = degs;
			
			//NSLog(@"atan( x=%d, y=%d ) = %3.3f [%d]", x, y, atan_result, degs);
		}
	}
}

/* arcsin helper */
int asin_helper[ASIN_HELPER_SZ];

void InitializeArcsinHelper() {
	for (int i = 0; i < ASIN_HELPER_MAX; i++) {
		asin_helper[i] = (int)(asin( ((double)i / ASIN_HELPER_MAX) ) * 180.0 / M_PI);
	}
}


/* RNG helper */
int rng_pool[RNG_SZ];
int *rng_ptr;
int *rng_final;
void InitializeRNGHelper() {
	rng_ptr = rng_pool;
	rng_final = rng_ptr + RNG_SZ;
	srand((int)time(0));
	for (int i = 0; i < RNG_SZ; i++) {
		rng_pool[i] = rand();
	}
}


int nonlinear_random_distribution(int *possibles, int *weights, int n) {
	int totalweight = 0;
	for (int i = 0; i < n; i++) {
		totalweight += weights[i];
	}
	if (!totalweight) return 0;
	int mark = rand() % totalweight;
	int target = 0;
	for (int i = 0; i < n; i++) {
		target += weights[i];
		if (mark < target) return possibles[i];
	}
	return possibles[n-1];
}



float ROOT_2 = 1.41421356;


/* Initialize the math helper */
void InitializeMathHelper() {
	InitializeHypHelper();
	InitializeAngleHelper();
	InitializeArctanHelper();
	InitializeArcsinHelper();
	InitializeRNGHelper();
	
	SQRT_3_D = sqrt(3);
	SQRT_3_F = sqrt(3);
	
	EXLog(ANY, INFO, @"Math helper initialized");
}
