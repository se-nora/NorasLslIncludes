/// gives an angular force you can apply to the center of mass of an object
/// <param param="localPullForceLocation">the local position relative to the root prim</param>
/// <param param="globalPullForceDirection">the directio the force is pulling at the <paramref param="localPullForceLocation"/></param>
vector GetOffsetTorque(vector assumedScale, rotation rootRot, vector localPullForceLocation, vector globalPullForceDirection)
{
    if (globalPullForceDirection == <0,0,0>)
    {
        return <0, 0, 0>;
    }
    if (assumedScale.x == 0 || assumedScale.y == 0 || assumedScale.z == 0)
    {
        return <0, 0, 0>;
    }

    float mass = llGetMass();
    vector scale = assumedScale;
    float volume = scale.x*scale.y*scale.z;

    rotation rotBetween = llRotBetween(localPullForceLocation, localPullForceLocation + globalPullForceDirection/rootRot);
    vector direction = llVecNorm(llRot2Euler(rotBetween));
    vector torque = direction*(1/llVecMag(<localPullForceLocation.x/assumedScale.x, localPullForceLocation.y/assumedScale.y, localPullForceLocation.z/assumedScale.z>))*llVecMag(globalPullForceDirection)*rootRot;///volume;
    //SetText(Dump(direction, torque));
    return torque;
}
vector GetOffsetTorqueOrig(rotation rootRot, vector localPullForceLocation, vector globalPullForceDirection)
{
    float mass = llGetMass();
    vector scale = llGetScale();
    float volume = scale.x*scale.y*scale.z;

    rotation rotBetween = llRotBetween(localPullForceLocation, localPullForceLocation + globalPullForceDirection/rootRot);
    vector direction = llVecNorm(llRot2Euler(rotBetween));
    vector torque = direction*llVecMag(localPullForceLocation)*llVecMag(globalPullForceDirection)*rootRot;///volume;
    //SetText(Dump(direction, torque));
    return torque;
}

vector GetOffsetRotPosition(vector initialPosition, vector centerPosition, rotation rotAmount)
{
    return (initialPosition - centerPosition) * rotAmount + centerPosition;
    /*
    vector offset = initialPosition - centerPosition;
                    
    //The following line calculates the new coordinates based on 
    //the rotation & offset
    vector finalPosition = offset * rotAmount;
    
    //Since the rotation is calculated in terms of our offset, we need to add
    //our original center_position back in - to get the final coordinates.
    finalPosition += centerPosition;
    
    return finalPosition;*/
}
