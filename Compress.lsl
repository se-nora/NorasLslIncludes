#ifndef NORA_COMPRESS
    #define NORA_COMPRESS
    #define CompressVector(v) "<" + CompressFloatString(v.x, false) + "," + CompressFloatString(v.y, false) + "," + CompressFloatString(v.z, false) + ">"
    #define CompressRotation(r) "<" + CompressFloatString(r.x, false) + "," + CompressFloatString(r.y, false) + "," + CompressFloatString(r.z, false) + "," + CompressFloatString(r.s, false) + ">"

    TestCompressFloatString()
    {
        llOwnerSay(Dump(CompressFloatString(0.0)));
        llOwnerSay(Dump(CompressFloatString(-0.0)));
        llOwnerSay(Dump(CompressFloatString(0.00001)));
        llOwnerSay(Dump(CompressFloatString(-0.00001)));
        llOwnerSay(Dump(CompressFloatString(0.5)));
        llOwnerSay(Dump(CompressFloatString(-0.5)));
        llOwnerSay(Dump(CompressFloatString(1.5)));
        llOwnerSay(Dump(CompressFloatString(-1.5)));
        llOwnerSay(Dump(CompressFloatString(0.55)));
        llOwnerSay(Dump(CompressFloatString(0.505)));
        llOwnerSay(Dump(CompressFloatString(0.5005)));
        llOwnerSay(Dump(CompressFloatString(0.50005)));
    }

    TestCompressParam()
    {
        llOwnerSay(Dump(CompressParam("0.5")));
        llOwnerSay(Dump(CompressParam("<0.5, -1, 0>")));
    }

    string CompressParam(string param, bool omitDefault)
    {
        string c = llGetSubString(param, 0, 0);
        
        if (c == "<")
        {
            if (llGetListLength(llParseString2List(param, [","],[])) == 4)
            {
                //llOwnerSay("rotation" + Dump(param));
                rotation r = (rotation)param;
                return CompressRotation(r);
            }
            vector r = (vector)param;
            return CompressVector(r);
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
                    return param;
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
                    // if we are here, then something non number looking was put -> string
                    return param;
                }

                i++;
            }
        }
        if (isMaybeFloat)
        {
            //llOwnerSay("Float" + Dump(param));
            return CompressFloatString((float)param, false);
        }
        //llOwnerSay("int" + Dump(param));
        int paramInt = (int)param;
        if (paramInt == 0 && omitDefault)
        {
            return "";
        }
        return param;
    }

    string CompressFloatString(float f, bool omitDefault)
    {
        string result = "";
        if (f == 0)
        {
            if (omitDefault)
            {
                return "";
            }

            return "0";
        }
        if (f < 0)
        {
            result = "-";
            f = -f;
        }

        if (f >= 1)
        {
            result += (string)((int)f);
        }
        
        int remains = (int)((f-(int)f)*1000000);
        if (!remains)
        {
            return result;
        }
        string pad;
        if (remains > 99999)
        {
            pad = "";
        }
        else if (remains > 9999)
        {
            pad = "0";
        }
        else if (remains > 999)
        {
            pad = "00";
        }
        else if (remains > 99)
        {
            pad = "000";
        }
        else if (remains > 9)
        {
            pad = "0000";
        }
        else
        {
            pad = "00000";
        }
        while (remains)
        {
            if (remains%10 == 0)
            {
                remains = remains/10;
            }
            else
            {
                return result + "." + pad + (string)remains;
            }
        }
        return result + "." + pad + (string)remains;
    }
#endif
