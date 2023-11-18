#define TypedConditionalReturn(TypeForName, type) type ConditionalReturn ## TypeForName(bool condition, type success, type fail)\
{\
    if (condition)\
    {\
        return success;\
    }\
\
    return fail;\
}
TypedConditionalReturn(Int, int)
TypedConditionalReturn(Bool, int)
TypedConditionalReturn(Float, float)
TypedConditionalReturn(Vector, vector)
TypedConditionalReturn(Rotation, rotation)
TypedConditionalReturn(List, list)
TypedConditionalReturn(String, string)
TypedConditionalReturn(Key, key)
