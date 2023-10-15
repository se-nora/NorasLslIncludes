#include "Nora\Sounds\Balloon.lsl"

#define OriginalBallonLinkSize <.42, .42, 1.2>
#define MinBallonLinkSize <0.05064, 0.05061, 0.13747>
#define MaxBallonLinkSize <.6, .6, 1.58915>
#define MinBalloonAlpha 1
#define MaxBalloonAlpha .7

#define MinPercentageHeliumFloat .3
#define MinSizeGravityHelium 1
#define NormalSizeGravityHelium -.3
#define MaxSizeGravityHelium -.4
#define MinSizeGravityAir 1
#define NormalSizeGravityAir .2
#define MaxSizeGravityAir .05

//SetColorAndScale, vector color, vector scale
#define BALLOON_SET_COLOR_AND_SCALE_MESSAGE "SetColorAndScale"

// auto set, the link number of the ballono link called "Balloon"
int BalloonLinkNumber;
bool IsHelium = true;

#define BalloonSize GetLinkSize(BalloonLinkNumber)
#define BalloonSizePercentage (llVecMag(BalloonSize-MinBallonLinkSize)/llVecMag(MaxBallonLinkSize-MinBallonLinkSize))

/// Returns approximated local Collision Pos
vector BalloonCollisionPos(vector balloonSize, vector collisionObjectPos)
{
    // the z is double the actual size...
    balloonSize.z *= .5;
    rotation rootRot = llGetRootRotation();
    return (llVecNorm(collisionObjectPos-llGetPos())*llVecMag(balloonSize)/2)/rootRot;
}

#define BalloonGravity ConditionalReturnFloat(\
    IsHelium,\
    ConditionalReturnFloat(\
        BalloonSizePercentage < 1,\
        ConditionalReturnFloat(BalloonSizePercentage<MinPercentageHeliumFloat,\
            (1-BalloonSizePercentage)*MinSizeGravityHelium + BalloonSizePercentage*NormalSizeGravityHelium,\
            NormalSizeGravityHelium-(llSin(BalloonSizePercentage - 1))/2),\
        (1-MinFloat(BalloonSizePercentage-1, 1))*NormalSizeGravityHelium + MinFloat(BalloonSizePercentage-1, 1)*MaxSizeGravityHelium),\
    ConditionalReturnFloat(\
        BalloonSizePercentage < 1,\
        (1-BalloonSizePercentage)*MinSizeGravityAir + BalloonSizePercentage*NormalSizeGravityAir,\
        (1-MinFloat(BalloonSizePercentage-1, 1))*NormalSizeGravityAir + MinFloat(BalloonSizePercentage-1, 1)*MaxSizeGravityAir))
#define SetColor(color) llSetLinkPrimitiveParamsFast(LINK_SET, [PRIM_COLOR, ALL_SIDES, color, (BalloonSizePercentage*MaxBalloonAlpha + (1-BalloonSizePercentage)*MinBalloonAlpha)])
#define SetRandomColor() SetColor(GetColorFromScale(llFrand(1), DefaultScaleColorArray))

SetScale(vector scale)
{
    vector myCurrentScale = llList2Vector(llGetLinkPrimitiveParams(BalloonLinkNumber, [PRIM_SIZE]), 0);
    float difference = scale.x/myCurrentScale.x;
    if (!llGetAttached())
    {
        llSetStatus(STATUS_PHYSICS, false);
    }
    llScaleByFactor(difference);
    llSetLinkPrimitiveParamsFast(BalloonLinkNumber, [PRIM_SIZE, <scale.x, scale.y, scale.z>]);
}
