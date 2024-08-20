
float AngleBetween(vector a, vector b) {
    // Calculate the dot product
    float dotProduct = a * b;

    // Calculate the magnitudes of the vectors
    float magA = llVecMag(a);
    float magB = llVecMag(b);

    // Calculate the cosine of the angle
    float cosTheta = dotProduct / (magA * magB);

    // Ensure cosTheta is within the valid range for acos
    cosTheta = Clamp(cosTheta, -1.0, 1.0);

    // Calculate and return the angle in radians
    return llAcos(cosTheta);
}

vector GetOffsetTorqueV4(vector forceAppliedToObject, vector offsetFromCenterOfMass) {
    return <(offsetFromCenterOfMass.y * forceAppliedToObject.z - offsetFromCenterOfMass.z * forceAppliedToObject.y), 
            (offsetFromCenterOfMass.z * forceAppliedToObject.x - offsetFromCenterOfMass.x * forceAppliedToObject.z), 
            (offsetFromCenterOfMass.x * forceAppliedToObject.y - offsetFromCenterOfMass.y * forceAppliedToObject.x)>;
}

vector GetOffsetTorqueV3(vector forceAppliedToObject, vector offsetFromCenterOfMass) {
    // Calculate the torque using the cross product
    vector torque = VecCross(
        offsetFromCenterOfMass,
        forceAppliedToObject * llSin(AngleBetween(offsetFromCenterOfMass, forceAppliedToObject)));
    return torque;
}

/// gives an angular force you can apply to the center of mass of an object
/// <param param="localPullForceLocation">the local position relative to the root prim</param>
/// <param param="globalPullForceDirection">the directio the force is pulling at the <paramref param="localPullForceLocation"/></param>
vector GetOffsetTorqueV2(vector assumedScale, rotation rootRot, vector localPullForceLocation, vector globalPullForceDirection)
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
vector GetOffsetTorqueV1(rotation rootRot, vector localPullForceLocation, vector globalPullForceDirection)
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
