#define FIND_LINK_NOT_FOUND -2

int FindLink(string name)
{
    int c = llGetNumberOfPrims();
    while (c > 0)
    {
        if (llGetLinkName(c) == name)
        {
            return c;
        }
        c--;
    }
    
    llSay(DEBUG_CHANNEL, "Could not find link '" + name + "'");
    return FIND_LINK_NOT_FOUND;
}

int FindLinkByKey(key objectKey)
{
    int c = llGetNumberOfPrims();
    while (c > 1)
    {
        if (llGetLinkKey(c) == objectKey)
        {
            return c;
        }

        c--;
    }

    //llSay(DEBUG_CHANNEL, "Could not find link '" + (string)objectKey + "'");
    return FIND_LINK_NOT_FOUND;
}

list FindLinks(string name)
{
    list ret = [];
    integer c = llGetNumberOfPrims();
    while (c > 0)
    {
        if (llGetLinkName(c) == name)
        {
            ret += c;
        }
        c--;
    }
    return ret;
}