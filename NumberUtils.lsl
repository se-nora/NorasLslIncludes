#ifndef NORA_NUMBERUTILS
    #define NORA_NUMBERUTILS

    #define Rand(min, max) (min + llFrand(max-min))

    #define MIN_PP(type, prepend) type Min ## prepend ## (type left, type right)\
    {\
        if (left < right)\
            return left;\
        return right;\
    }
    #define MAX_PP(type, prepend) type Max ## prepend ## (type left, type right)\
    {\
        if (left > right)\
            return left;\
        return right;\
    }
    MIN_PP(float,Float)
    MAX_PP(float,Float)
    MIN_PP(int,Int)
    MAX_PP(int,Int)
    #define Min(left, right) MinFloat(left, right)
    #define MinF(left, right) MinFloat(left, right)
    #define Max(left, right) MaxFloat(left, right)
    #define MaxF(left, right) MaxFloat(left, right)
    #define MaxI(left, right) MaxInt(left, right)
    #define MinI(left, right) MinInt(left, right)

    #define CLAMP_PP(type, prepend) type Clamp ## prepend ## (type value, type min, type max)\
    {\
        if (value > max) return max;\
        if (value < min) return min;\
        return value;\
    }
    CLAMP_PP(float,Float)
    #define Clamp(value, min, max) ClampFloat(value, min, max)
    #define ClampF(value, min, max) ClampFloat(value, min, max)
    CLAMP_PP(int,Int)
    #define ClampI(value, min, max) ClampInt(value, min, max)

    #define AddTowards(variable, target, howMuch)\
    {\
        float howMuchos = llFabs(howMuch);\
        float diff = llFabs(target-variable);\
        howMuchos = Min(howMuchos, diff);\
        if (variable > target)\
        {\
            variable -= howMuchos;\
            if (variable < target)\
            {\
                variable = target;\
            }\
        }\
        else if (variable < target)\
        {\
            variable += howMuchos;\
            if (variable > target)\
            {\
                variable = target;\
            }\
        }\
    }
#endif
