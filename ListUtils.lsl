#define RandomListItem(listType, listName) llList2 ## listType(listName, (int)llFrand(llGetListLength(listName)))

#define RandomStringListItem(listName) RandomListItem(String, listName)
#define RandomKeyListItem(listName) RandomListItem(Key, listName)
#define RandomIntListItem(listName) RandomListItem(Int, listName)
#define RandomBoolListItem(listName) RandomListItem(Int, listName)
#define RandomFloatListItem(listName) RandomListItem(Float, listName)
#define RandomVectorListItem(listName) RandomListItem(Vector, listName)
#define RandomRotListItem(listName) RandomListItem(Rot, listName)

#define SumList(capitalType, type) type Sum ## capitalType(list data) \
{ \
    int i = llGetListLength(data); \
    type ret = 0; \
    while (i-- > 0) \
    { \
        ret += llList2 ## capitalType ## (data, i); \
    } \
    return ret; \
}
#define MaxList(capitalType, type) type MaxList ## capitalType(list data) \
{ \
    int i = 0; \
    int n = llGetListLength(data); \
    type ret = 0; \
    while (i < n) \
    { \
        type value = llList2 ## capitalType ## (data, i++); \
        if (value > ret || i == 1) ret = value; \
    } \
    return ret; \
}
#define MinList(capitalType, type) type MinList ## capitalType(list data) \
{ \
    int i = 0; \
    int n = llGetListLength(data); \
    type ret = 0; \
    while (i < n) \
    { \
        type value = llList2 ## capitalType ## (data, i++); \
        if (value < ret || i == 1) ret = value; \
    } \
    return ret; \
}

SumList(Float, float)
SumList(Int, int)
MaxList(Float, float)
MaxList(Int, int)
MinList(Float, float)
MinList(Int, int)
