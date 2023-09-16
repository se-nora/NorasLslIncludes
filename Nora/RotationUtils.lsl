/// gives an angular force you can apply to the center of mass of an object
/// <param param="localPullForceLocation">the local position relative to the root prim</param>
/// <param param="globalPullForceDirection">the directio the force is pulling at the <paramref param="localPullForceLocation"/></param>
vector GetOffsetTorque(vector assumedScale, rotation rootRot, vector localPullForceLocation, vector globalPullForceDirection)
{
    float mass = llGetMass();
    vector scale = assumedScale;
    float volume = scale.x*scale.y*scale.z;

    rotation rotBetween = llRotBetween(localPullForceLocation, localPullForceLocation + globalPullForceDirection/rootRot);
    vector direction = llVecNorm(llRot2Euler(rotBetween));
    vector torque = direction*(1/llVecMag(<localPullForceLocation.x/assumedScale.x,localPullForceLocation.y/assumedScale.y,localPullForceLocation.z/assumedScale.z>))*llVecMag(globalPullForceDirection)*rootRot;///volume;
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
