//
//  MathHelper.h
//
//  Created by Jason Fieldman on 9/4/10.
//  Copyright 2010 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

/* geo radius */
#define kEarthRadiusMiles   3963.191
#define kEarthRadiusKMeters 6378.137

/* Constants */
extern float  SQRT_3_F;
extern double SQRT_3_D;

/* Rotation radian helpers */
#define M_PI_TEN (M_PI * 10)

/* hyp helper */
#define HYP_HELPER_MAX 128
#define HYP_HELPER_SHIFT 7
#define HYP_HELPER_SZ  (HYP_HELPER_MAX * HYP_HELPER_MAX)
#define HYP_OF(_x, _y) hyp_helper[_x + (_y << HYP_HELPER_SHIFT)]
extern float hyp_helper[HYP_HELPER_SZ];

/* angle helper */
#define DEGREES_NUM 360
extern float deg_to_rad_array[DEGREES_NUM];
extern float sin_of_deg_array[DEGREES_NUM];
extern float cos_of_deg_array[DEGREES_NUM];
#define _DEG2RAD(_d) deg_to_rad_array[_d]
#define _SIN_DEG(_d) sin_of_deg_array[_d]
#define _COS_DEG(_d) cos_of_deg_array[_d]

/* arctan helper */
#define ATAN_HELPER_MAX 128
#define ATAN_HELPER_HALF 64
#define ATAN_HELPER_SHIFT 7
#define ATAN_HELPER_SZ  (ATAN_HELPER_MAX * ATAN_HELPER_MAX)
#define ATAN_OF(_x, _y) atan_helper[(_x + ATAN_HELPER_HALF) + ((_y + ATAN_HELPER_HALF) << ATAN_HELPER_SHIFT)]
extern int atan_helper[ATAN_HELPER_SZ];

/* arcsin helper */
#define ASIN_HELPER_MAX    1024
#define ASIN_HELPER_MAX_M1 1023
#define ASIN_HELPER_SZ  ASIN_HELPER_MAX
#define ASIN_OF(_v) asin_helper[ (int)(_v * ASIN_HELPER_MAX_M1) ]
extern int asin_helper[ASIN_HELPER_SZ];
static inline int SAFE_FULL_ASIN_OF(double _v) {
	double tv = _v;
	if (tv < 0) tv *= -1;
	if (tv > 1.0) tv = 1.0;
	int ang = ASIN_OF(tv);
	if (_v < 0) ang *= -1;
	return ang;
}

/* Circle/point intersection detection */
/* Circle/point intersection */
static inline BOOL isPointInCircle(int px, int py, int cx, int cy, int radius) {
	int xdis = abs(px - cx);
	int ydis = abs(py - cy);
	if (xdis > radius || ydis > radius) return NO;
	return ((int)HYP_OF(xdis, ydis) <= radius);
}

/* Fast random number generator */
#define RNG_SZ       8192
#define RNG_SZ_SHIFT 0xFFF
extern int rng_pool[RNG_SZ];
extern int *rng_ptr;
extern int *rng_final;
static inline int fastRand() {
	rng_ptr++;
	if (rng_ptr == rng_final) rng_ptr = rng_pool;
	return *rng_ptr;
}

static inline float floatBetween(float low, float high) {
	float norm = (( rand() % 65536 ) / 65536.0 );
	return low + (high - low) * norm;
}

static inline double doubleBetween(double low, double high) {
	double norm = (( rand() % 1000000000 ) / 1000000000.0 );
	return low + (high - low) * norm;
}


/* Fast integer sqrt helper */
__attribute__((unused)) static uint32_t FastIntSQRT(uint32_t a_nInput) {
    uint32_t op  = a_nInput;
    uint32_t res = 0;
    uint32_t one = 1uL << 30; // The second-to-top bit is set: use 1u << 14 for uint16_t type; use 1uL<<30 for uint32_t type
	
    // "one" starts at the highest power of four <= than the argument.
    while (one > op) {
        one >>= 2;
    }
	
    while (one != 0) {
        if (op >= res + one) {
            op = op - (res + one);
            res = res +  2 * one;
        }
        res >>= 1;
        one >>= 2;
    }
    return res;
}

/* floating point modulus functions */
__attribute__((unused)) static double s_modulus_double(double a, double b) {
	int result = (int)( a / b );
	return a - (double)( result ) * b;
}

__attribute__((unused)) static float s_modulus_float(float a, float b) {
	int result = (int)( a / b );
	return a - (float)( result ) * b;
}


int nonlinear_random_distribution(int *possibles, int *weights, int n);

/* 50/50 chance to invert the integer (* -1) */
__attribute__((unused)) static int random_invert(int i) {
	if (rand() & 1) {
		return i * -1;
	}
	return i;
}

extern float ROOT_2;

/* Initialize the math helper */
void InitializeMathHelper(void);

