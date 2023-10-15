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

MIN_PP(float,)
MAX_PP(float,)
MIN_PP(float,Float)
MAX_PP(float,Float)
MIN_PP(int,Int)
MAX_PP(int,Int)

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
