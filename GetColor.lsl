#ifndef GETCOLORLSL
    #define GETCOLORLSL
    #define GetColorFromKey GetColorForKey
    list DefaultScaleColorArray = 
    [
        <1,0,0>,
        <0,1,0>,
        <0,0,1>,
        <1,0,0>
    ];

    vector GetRandomColor()
    {
        float p = llFrand(1);
        integer colorIndex = (integer)(p*(llGetListLength(DefaultScaleColorArray)-1));
        vector leftColor = llList2Vector(DefaultScaleColorArray, colorIndex);
        vector rightColor = llList2Vector(DefaultScaleColorArray, colorIndex+1);
        
        float blendPos = p*(llGetListLength(DefaultScaleColorArray)-1)*2 - colorIndex*2;
        vector resultColor;
        if (blendPos < 1)
        {
            resultColor = leftColor + rightColor * blendPos;
        }
        else
        {
            resultColor = rightColor + leftColor * (2-blendPos);
        }
        //llSetText((string)leftColor + " / " + (string)rightColor 
        //  + " @ "+ (string)blendPos + " = " + (string)resultColor, <1,1,1>,1);
        return resultColor;
    }

    vector GetColorFromScale(float percentage, list colorScale)
    {
        integer colorIndex = (integer)(percentage*(llGetListLength(colorScale)-1));
        vector leftColor = llList2Vector(colorScale, colorIndex);
        vector rightColor = llList2Vector(colorScale, colorIndex+1);
        
        float blendPos = percentage*(llGetListLength(colorScale)-1)*2 - colorIndex*2;
        vector resultColor;
        if (blendPos < 1)
        {
            resultColor = leftColor + rightColor * blendPos;
        }
        else
        {
            resultColor = rightColor + leftColor * (2-blendPos);
        }
        //llSetText((string)leftColor + " / " + (string)rightColor 
        //  + " @ "+ (string)blendPos + " = " + (string)resultColor, <1,1,1>,1);
        return resultColor;
    }

    // takes the hex (for example 0F) and divides it by 255 to return a value between 0 and 1
    float GetPercentageFromHex(string hex)
    {
        return (float)((integer)("0x" + hex))/255.0;
    }

    // converts the first 6 characters of a key to a color
    vector GetColorForKey(key k)
    {
        return <GetPercentageFromHex(llGetSubString((string)k,0,1)),
            GetPercentageFromHex(llGetSubString((string)k,2,3)),
            GetPercentageFromHex(llGetSubString((string)k,4,5))>;
    }
#else
// nothing
#endif
