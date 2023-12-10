#ifndef NORA
    #define NORA
    #include "ConvenienceRenames.lsl"
    
    #define MAX_PUBLIC_MESSAGE_LENGTH 1024
    #define UsedMemoryPercentage (100*llGetUsedMemory()/llGetMemoryLimit())

    #define Stringify(...) #__VA_ARGS__

    #define PPFirstParam_(N, ...) N
    #define PPFirstParam(args) PPFirstParam_(args)

    #define PPconcat(A, B) A ## B
    #define PPParamsAsList(...) [__VA_ARGS__]
    #define Dump(...) #__VA_ARGS__ ## + ": " + llList2CSV([] + [__VA_ARGS__])
    #define Dumpl(...) #__VA_ARGS__ ## + ": " + llList2CSV(__VA_ARGS__)
    #define OwnerSayDump(...) llOwnerSay(#__VA_ARGS__ ## + ": " + llList2CSV([] + [__VA_ARGS__]))

    #ifdef VERBOSE
    #define Verbose(...) llOwnerSay(__VA_ARGS__)
    #else
    #define Verbose(...)
    #endif

    #define Trim(text) llStringTrim(text, STRING_TRIM)
    #define Split(text, by) llParseString2List(text, [by], [])
    #define SetText(text) SetLinkText(LINK_THIS, text)
    #define SetLinkText(link, text) llSetLinkPrimitiveParamsFast(link, [PRIM_TEXT, text, <1,1,1>, 1])

    bool HasSeatedAvatar()
    {
        key lastKey = llGetLinkKey(llGetNumberOfPrims());
        return lastKey == llGetOwnerKey(lastKey);
    }

    bool HasInventory(list names)
    {
        int i = llGetListLength(names);
        while(i--)
        {
            if (llGetInventoryKey(llList2String(names, i)) == NULL_KEY)
            {
                return false;
            }
        }
        return true;
    }
    
    #define GRAVITY 9.8

    // NOTE: the geometric center is bullshit, its the average of all linked prims center, not geometric at all, use bounding box instead
    //#define GetGeometricCenterGlobalPos() (llGetGeometricCenter()*llGetRootRotation() + llGetRootPosition())
    
    #define DisableParticles() llParticleSystem([]);
    #define DisableAllParticles() llLinkParticleSystem(LINK_SET, [])
    #define DisableLinkParticles(link) llLinkParticleSystem(link, [])

    #define SetTimer(interval) llSetTimerEvent(interval)
    #define Sleep(ms) llSleep(ms/1000.0)

    #define GetCallerInfo() __SHORTFILE__ + ":" + (string) ## __LINE__

    #define GetObjectPos(k) llList2Vector(llGetObjectDetails(k, [OBJECT_POS]), 0)
    #define GetObjectVel(k) llList2Vector(llGetObjectDetails(k, [OBJECT_VELOCITY]), 0)
    #define GetObjectRot(k) llList2Rot(llGetObjectDetails(k, [OBJECT_ROT]), 0)
    #define GetObjectScale(k) llList2Vector(llGetObjectDetails(k, [OBJECT_SCALE]), 0)
    #define GetLinkPosLocal(link) llList2Vector(llGetLinkPrimitiveParams(link, [PRIM_POS_LOCAL]), 0)
    #define GetLinkSize(link) llList2Vector(llGetLinkPrimitiveParams(link, [PRIM_SIZE]), 0)
    #define GetRezzerKey(k) llList2Key(llGetObjectDetails(k, [OBJECT_REZZER_KEY]), 0)

    #define GetRootScale() llList2Vector(llGetLinkPrimitiveParams(LINK_ROOT, [PRIM_SIZE]), 0)

    #define Convert(elementType, elements, elementGetter, converter) {\
        list ret;\
        int i = 0;\
        int c = llGetListLength(elements);\
        while (i < c)\
        {\
            elementType element = elementGetter(elements, i++);\
            ret += converter;\
        }\
        elements = ret;\
    }

    /// Converts one string value to its respective lsl type (int/vector/float/rotation)
    list ConvertToLslType(string param)
    {
        string char = llGetSubString(param, 0, 0);
        
        if (char == "<")
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
        if (char == "-")
        {
            i = 1;
        }
        while (i < length)
        {
            char = llGetSubString(param, i, i);
            if (char == ".")
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
                int charValue = GetCharValue(char);
                
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

    // returns 1 if s1 is greater than s2, -1 if otherwise, 0 if equal
    int StringCompare(string s1, string s2)
    {
        if (s1 == s2)
            return 0;

        if (s1 == llList2String(llListSort([s1, s2], 1, true), 0))
            return -1;

        return 1;
    }

    #include "Sounds\Female.lsl"
    #include "Sounds\Male.lsl"
    #include "Sounds\Fireplace.lsl"
    #include "Sounds\Piano.lsl"
    
    #include "Rope.lsl"
    
    #include "AnimationUtils.lsl"
    #include "AvatarUtils.lsl"
    #include "BoundingBox.lsl"
    #include "ConditionalReturn.lsl"
    #include "FindLink.lsl"
    #include "GetColor.lsl"
    #include "GetName.lsl"
    #include "Intersects.lsl"
    #include "ListUtils.lsl"
    #include "NumberUtils.lsl"
    #include "ResetUtils.lsl"
    #include "RotationUtils.lsl"
    #include "VectorUtils.lsl"
    #include "CharacterUtils.lsl"
    #include "Compress.lsl"
    #include "List2CSV.lsl"
    #include "IPC.lsl"
    #include "GetLinkVelocity.lsl"
#endif
