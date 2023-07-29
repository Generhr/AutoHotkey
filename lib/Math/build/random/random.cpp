#include "pch.h"
#include "random.h"

#include <random>

static std::mt19937_64 rng(std::random_device{}());

__DECL void seed(unsigned __int64 seed) {
    rng.seed(seed);
}

__DECL __int64 uniform_int64(__int64 min, __int64 max) {
    return std::uniform_int_distribution<__int64>{min, max}(rng);
}

__DECL double uniform_double(double min, double max) {
    return std::uniform_real_distribution<double>{min, max}(rng);
}

__DECL double normal(double mean, double deviation) {
    return std::normal_distribution<double>{mean, deviation}(rng);
}
