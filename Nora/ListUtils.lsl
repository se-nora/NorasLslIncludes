#define RandomListItem(listType, listName) llList2 ## listType(listName, (int)llFrand(llGetListLength(listName)))

#define RandomStringListItem(listName) RandomListItem(String, listName)
#define RandomKeyListItem(listName) RandomListItem(Key, listName)
#define RandomIntListItem(listName) RandomListItem(Int, listName)
#define RandomBoolListItem(listName) RandomListItem(Int, listName)
#define RandomFloatListItem(listName) RandomListItem(Float, listName)
#define RandomVectorListItem(listName) RandomListItem(Vector, listName)
#define RandomRotListItem(listName) RandomListItem(Rot, listName)
