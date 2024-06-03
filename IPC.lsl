
string GetLinkPrimitiveParamsAsSendableString(list params)
{
    string s;
    int i = 0;
    int c = llGetListLength(params);
    while (i < c)
    {
        int link = llList2Int(params, i);
        int param = llList2Int(params, i+1);
        if (i > 0)
        {
            s+=",";
        }
        s += (string)param +","+List2CSV(llGetLinkPrimitiveParams(link, [param]));
        i+=2;
    }
    return s;
}


/// Converts one string value to its respective lsl type (int/vector/float/rotation)
list ConvertToLslType(string param)
{
    string c = llGetSubString(param, 0, 0);
    
    if (c == "<")
    {
        if (llGetListLength(llParseString2List(param, [","],[])) == 4)
        {
            //llOwnerSay("rotation" + Dump(param));
            return [(rotation)param];
        }
        //llOwnerSay("vector" + Dump(param));
        return [(vector)param];
    }
    
    bool isMaybeFloat = false;
    int dotCount = 0;
    int length = llStringLength(param);
    int i = 0;
    if (c == "-")
    {
        i = 1;
    }
    while (i < length)
    {
        c = llGetSubString(param, i, i);
        if (c == ".")
        {
            isMaybeFloat = true;
            dotCount++;
            // more than one decimal point can be considered param is a string
            if (dotCount > 1)
            {
                //llOwnerSay("string" + Dump(param));
                return [param];
            }
            i++;
        }
        else
        {
            int charValue = GetCharValue(c);
            
            // '0' - '9'
            bool isNumeric = charValue >= 48 && charValue <= 57;

            if (!isNumeric)
            {
                //llOwnerSay("string" + Dump(param));
                // if we are here, then something non number looking was put -> string
                return [param];
            }

            i++;
        }
    }
    if (isMaybeFloat)
    {
        //llOwnerSay("Float" + Dump(param));
        return [(float)param];
    }
    //llOwnerSay("int" + Dump(param));
    return [(int)param];
}