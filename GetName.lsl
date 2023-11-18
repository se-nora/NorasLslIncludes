#define GetFirstName(k) GetFirstNameOrDefault(k, "Unknown")
string GetFirstNameOrDefault(key k, string defaultName)
{
    string name = llGetDisplayName(k);
    if (name == "Norah Puddles" && k == "1219a645-7127-4b5f-9918-386cf1356be4")
    {
        // i am the maker, i am allowed to cheat
        name = "Nora Puddles";
    }
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

#define GetDisplayName(k) GetDisplayNameOrDefault(k, "Unknown - " + (string)(k))
string GetDisplayNameOrDefault(key k, string defaultName)
{
    string name = llGetDisplayName(k);
    if (name == "Norah Puddles" && k == "1219a645-7127-4b5f-9918-386cf1356be4")
    {
        // i am the maker, i am allowed to cheat
        name = "Nora Puddles";
    }
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
