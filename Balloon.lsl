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
// follow target key variable
key FollowTarget;

int RopeLinkNumber;
vector RopeLinkNumberLocalPos;
// The length of the simulated rope. (It will stretch slightly longer than this, though)
float RopeLength = 1;
// this reduces the rotational pull effect from the rope
#define AngularFullDampeningFactor .25
// This dampens a fraction of the object's velocity every 0.1 seconds, if the rope is stretched.
#define VelocityDampeningFactor .4
// How much the object "bounces" back after stretching the rope to the limit of its length. This applies if the rope is stretched suddenly. 0.4 means it will bounce back with  40% of its original velocity. Setting this to below 0 will make the constraint act more stretchy than ropes normally do. Setting this to above 1 will make it unstable and dangerous.
#define BounceBackImpulseFactor .4
// The force ForceFactor of the rope. This applies when the rope is stretched slowly - in which case, it acts sort of like a spring.
#define ForceFactor 16.0

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
