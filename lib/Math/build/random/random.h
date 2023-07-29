#pragma once

#define __DECL __declspec(dllexport)

#ifdef __cplusplus
extern "C"
{
#endif

    __DECL void seed(unsigned __int64 seed);

    __DECL __int64 uniform_int64(__int64 min, __int64 max);

    __DECL double uniform_double(double min, double max);

    __DECL double normal(double mean, double deviation);

#ifdef __cplusplus
} // extern "C"
#endif
