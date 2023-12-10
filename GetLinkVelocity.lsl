
vector GetLinkVelocity(vector localCenterOfMass, vector localVelocity, vector linkLocalPosition, vector localOmega)
{
    vector relCenterLinkPosition = linkLocalPosition - localCenterOfMass;
    vector linkVelocity = -<
        relCenterLinkPosition.y * localOmega.z - relCenterLinkPosition.z * localOmega.y,
        relCenterLinkPosition.z * localOmega.x - relCenterLinkPosition.x * localOmega.z,    
        relCenterLinkPosition.x * localOmega.y - relCenterLinkPosition.y * localOmega.x>;

    return localVelocity + linkVelocity;
}

list LinkAccelerations = [];

integer LINK_ACCELERATIONS_INITIAL_VELOCITY = 1;
integer LINK_ACCELERATIONS_LAST_CALCED_ACCEL = 2;

integer LINK_ACCELERATIONS_STRIDE = 3;

vector GetLinkAcceleration(integer link, vector linkVelocity, float deltaTime, float smoothingFactor)
{
    integer accelerationIndex = llListFindList(LinkAccelerations, [link]);
    vector lastVelocity;
    vector lastCalcedAccel;
    if (accelerationIndex >= 0)
    {
        lastVelocity = llList2Vector(LinkAccelerations, accelerationIndex+LINK_ACCELERATIONS_INITIAL_VELOCITY);
        lastCalcedAccel = llList2Vector(LinkAccelerations, accelerationIndex+LINK_ACCELERATIONS_LAST_CALCED_ACCEL);
    }
    else
    {
        lastVelocity = linkVelocity;
        lastCalcedAccel = linkVelocity;
    }
    vector velocityDiff = (linkVelocity - lastVelocity)/deltaTime;
    vector accel = velocityDiff/deltaTime;

    //smoothening
    lastCalcedAccel = (lastCalcedAccel*(smoothingFactor-1) + accel)/smoothingFactor;

    //lastCalcedAccel = accel;
    lastVelocity = linkVelocity;

    if (accelerationIndex == -1)
    {
        LinkAccelerations += [link, lastVelocity, lastCalcedAccel];
    }
    else
    {
        LinkAccelerations = llListReplaceList(
            LinkAccelerations,
            [lastVelocity, lastCalcedAccel],
            accelerationIndex+1,
            accelerationIndex+LINK_ACCELERATIONS_STRIDE-1);
    }
    
    return lastCalcedAccel;
}
