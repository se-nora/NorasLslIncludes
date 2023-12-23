#define GetFirstName(k) GetFirstNameOrDefault(k, "Unknown")
#define GetFirstLegacyName(k) GetFirstLegacyNameOrDefault(k, "Unknown")

string GetFirstNameOrDefault(key k, string defaultName)
{
    string name = llGetDisplayName(k);
    
    if (name == "")
    {
        name = llKey2Name(k);
    }
    if (name == "")
    {
        return defaultName;
    }

    list nameAsList = llParseString2List(name, [" "], []);

    name = llDumpList2String(llList2List(nameAsList, 0, llGetListLength(nameAsList)-2), " ");
    
    return name;
}

string GetFirstLegacyNameOrDefault(key k, string defaultName)
{
    string name = llKey2Name(k);

    if (name == "")
    {
        return defaultName;
    }

    list nameAsList = llParseString2List(name, [" "], []);

    name = llDumpList2String(llList2List(nameAsList, 0, llGetListLength(nameAsList)-2), " ");
    
    return name;
}

#define GetDisplayName(k) GetDisplayNameOrDefault(k, "Unknown - " + (string)(k))
string GetDisplayNameOrDefault(key k, string defaultName)
{
    string name = llGetDisplayName(k);

    if (name == "")
    {
        name = llKey2Name(k);
    }

    if (name == "")
    {
        return defaultName;
    }
    
    return name;
}
