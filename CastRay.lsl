
/// returns [hasHitSomething, hitKey, hitPos, hitNormals];
/// hitKey is "floor" if it hit the ground
list CastRay(vector fromGlobal, vector toGlobal, int hitCount)
{
    /*vector myPos = llGetPos();
    vector lookAtDiff = (toGlobal-myPos)-(fromGlobal-myPos);
    llSetLinkPrimitiveParamsFast(FindLink("arrow pointer vector"),
    [
        PRIM_POS_LOCAL, (fromGlobal-myPos)/llGetRootRotation(),
        PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, llVecNorm(lookAtDiff))/llGetRootRotation(),
        PRIM_SIZE, <.2,.2,2>*llVecMag(lookAtDiff)
    ]);*/

    // NOTE: key is 0
    #define RAY_STRIDE 3

    list castResult = llCastRay(fromGlobal, toGlobal, [RC_MAX_HITS, hitCount, /*RC_REJECT_TYPES, RC_REJECT_AGENTS, */RC_DATA_FLAGS, RC_GET_ROOT_KEY | RC_GET_NORMAL]);

    int hits = llList2Int(castResult, -1);
    
    vector hitPos = toGlobal;
    vector hitNormals = <0,0,0>;

    if (!hits)
    {
        jump foundNothing;
    }
    
    key rootKey = llGetKey();
    key foundKey = NULL_KEY;
    int hit = 0;
    while (hit < hits)
    {
        foundKey = llList2Key(castResult, RAY_STRIDE * hit);
        
        if (foundKey == NULL_KEY)
        {
            hitPos = llList2Vector(castResult, RAY_STRIDE * hit + 1);
            hitNormals = llList2Vector(castResult, RAY_STRIDE * hit + 2);
            foundKey = "floor";
            //SetText("Found floor on hit "+(string)(hit+1) + "/"+(string)hits);
        }
        else
        {
            if (foundKey == rootKey)
            {
                hitPos = llList2Vector(castResult, RAY_STRIDE*hit + 1);
                hitNormals = llList2Vector(castResult, RAY_STRIDE*hit + 2);
                //SetText("Found self ("+llKey2Name(foundKey)+")");
                jump continue;
            }
            else
            {
                //SetText("Found " + llKey2Name(foundKey)+ " ("+(string)foundKey+") on hit "+(string)(hit+1) + "/"+(string)hits);
            }
        }
        hitPos = llList2Vector(castResult, RAY_STRIDE*hit + 1);
        hitNormals = llList2Vector(castResult, RAY_STRIDE*hit + 2);

        jump break;
        
        @continue;
        hit++;
    }
    @foundNothing;
    //setParams(localStartPos, localStartPos, MyOriginalRot);
    //SetText("Found nothing");
    return [false];
    @break;
    //SetText("params:\h" + (string)hits + "\nfrom " + (string)fromGlobal + "\nto " + (string)toGlobal + "\nhit " + (string)hitPos + "\nn " + (string)hitNormals);

    return [true, foundKey, hitPos, hitNormals];
    //adjust(localStartPos, hitPos, hitNormals);
}