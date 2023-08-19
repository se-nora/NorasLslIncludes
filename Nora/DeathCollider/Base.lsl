#include "Nora\Nora.lsl"

BoundingBoxData GetDeathBoundingBox(key k)
{
    BoundingBoxData boundingBoxData = GetBoundingBoxData(k);
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);
    bbRot = llEuler2Rot(<0, PI/2, 0>) * bbRot;

    // sadly the rotation of the fall anim is not "straight"
    if (HasFallenForward)
    {
        bbRot *= llEuler2Rot(<0,0,-.18>);
        bbPos += llRot2Up(bbRot)*(bbSize.z-.5);
    }
    else
    {
        bbRot *= llEuler2Rot(<0,0,.3>);
        bbPos -= llRot2Up(bbRot)*(bbSize.z-.5);
    }

    bbSize.x = bbSize.z;
    bbPos.z -= bbSize.z/2 - bbSize.x/2;
    bbSize.z += 1;
    bbSize.y += 1;

    return [bbPos, bbRot, bbSize];
}
