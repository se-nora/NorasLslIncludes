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

    #define SetTimer(interval) llSetTimerEvent(interval)

    #define GetCallerInfo() __SHORTFILE__ + ":" + (string) ## __LINE__

    #define GetObjectPos(k) llList2Vector(llGetObjectDetails(k, [OBJECT_POS]), 0)
    #define GetObjectRot(k) llList2Rot(llGetObjectDetails(k, [OBJECT_ROT]), 0)
    #define GetObjectScale(k) llList2Vector(llGetObjectDetails(k, [OBJECT_SCALE]), 0)
    #define GetLinkPosLocal(link) llList2Vector(llGetLinkPrimitiveParams(link, [PRIM_POS_LOCAL]), 0)
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

    // returns 1 if s1 is greater than s2, -1 if otherwise, 0 if equal
    int StringCompare(string s1, string s2)
    {
        if (s1 == s2)
            return 0;

        if (s1 == llList2String(llListSort([s1, s2], 1, true), 0))
            return -1;

        return 1;
    }

    #include "Nora\Sounds\Female.lsl"
    #include "Nora\Sounds\Male.lsl"
    #include "Nora\Sounds\Fireplace.lsl"
    #include "Nora\Sounds\Piano.lsl"
    
    #include "Rope.lsl"
    
    #include "VectorUtils.lsl"
    #include "RotationUtils.lsl"
    #include "NumberUtils.lsl"
    #include "AnimationUtils.lsl"
    #include "AvatarUtils.lsl"
    #include "BoundingBox.lsl"
    #include "ConditionalReturn.lsl"
    #include "FindLink.lsl"
    #include "GetColor.lsl"
    #include "GetName.lsl"
    #include "ListUtils.lsl"
    #include "ResetUtils.lsl"
    #include "Intersects.lsl"
#endif
