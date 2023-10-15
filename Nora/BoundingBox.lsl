#define BoundingBoxData list
#define GetBoundingBoxPosition(boundingBoxData) llList2Vector(boundingBoxData, 0)
#define GetBoundingBoxRotation(boundingBoxData) llList2Rot(boundingBoxData, 1)
#define GetBoundingBoxSize(boundingBoxData) llList2Vector(boundingBoxData, 2)
#define GetBoundingBoxRootRotation(boundingBoxData) llList2Rot(boundingBoxData, 3)
#define GetBoundingBoxObjectDescription(boundingBoxData) llList2String(boundingBoxData, 4)
#define GetBoundingBoxLegacySize(boundingBoxData) llList2Vector(boundingBoxData, 5)

#define GetEncapsulatingSphereRadius(boundingBoxData) llVecMag(GetBoundingBoxSize(boundingBoxData))

// returns [center, rot, size, root_rotation, object_desc, legacySize] of the object
BoundingBoxData GetBoundingBoxData(key objectId)
{
    list l = llGetBoundingBox(objectId);
    vector min = llList2Vector(l, 0);
    vector max = llList2Vector(l, 1);
    vector legacySize;
    vector size = legacySize = <max.x-min.x, max.y-min.y, max.z-min.z>;

    l = llGetObjectDetails(objectId, [OBJECT_POS, OBJECT_ROT, OBJECT_DESC]);
    vector objectPos = llList2Vector(l, 0);
    rotation objectRot = llList2Rot(l, 1);
    string objectDesc = llList2String(l, 2);

    vector centerOffset = (min + max)/2.0; 
    rotation rot = objectRot;
    
    vector up = llRot2Up(rot);
    vector down = -up;
    vector left = llRot2Left(rot);
    vector right = -left;
    vector fwd = llRot2Fwd(rot);
    vector back = -fwd;
    
    if (
           up.z > down.z
        && up.z > left.z
        && up.z > right.z
        && up.z > fwd.z
        && up.z > back.z)
    {
        // all good
    }
    else if (
           down.z > up.z
        && down.z > left.z
        && down.z > right.z
        && down.z > fwd.z
        && down.z > back.z)
    {
        // rotate by 180° and we are good
        rot = llEuler2Rot(<PI, 0, 0>) * rot;
    }
    else if (
           left.z > up.z
        && left.z > down.z
        && left.z > right.z
        && left.z > fwd.z
        && left.z > back.z)
    {
        rot = llEuler2Rot(<-PI/2, 0, 0>) * rot;
        size = <size.x, size.z, size.y>;
    }
    else if (
           right.z > up.z
        && right.z > down.z
        && right.z > left.z
        && right.z > fwd.z
        && right.z > back.z)
    {
        rot = llEuler2Rot(<PI/2, 0, 0>) * rot;
        size = <size.x, size.z, size.y>;
    }
    else if (
           fwd.z > up.z
        && fwd.z > down.z
        && fwd.z > left.z
        && fwd.z > right.z
        && fwd.z > back.z)
    {
        rot = llEuler2Rot(<0, PI/2, 0>) * rot;
        size = <size.z, size.y, size.x>;
    }
    else if (
           back.z > up.z
        && back.z > down.z
        && back.z > left.z
        && back.z > right.z
        && back.z > fwd.z)
    {
        rot = llEuler2Rot(<0, -PI/2, 0>) * rot;
        size = <size.z, size.y, size.x>;
    }

    //SetText(Dump(up, down, left, right, fwd, back));

    centerOffset *= rot;

    //rot = llRotBetween(<0,1,0>, llVecNorm(centerOffset));
    //SetText(Dump(min, max, centerOffset));
    
    vector center = objectPos + (centerOffset * rot); 

    return [center, rot, size, objectRot, objectDesc, legacySize, "hi"];
}


// Function to check if two bounding boxes intersect
bool IntersectsBoundingBox(BoundingBoxData boundingBox1, BoundingBoxData boundingBox2)
{
    vector boundingBox1Pos = GetBoundingBoxPosition(boundingBox1);
    vector boundingBox2Pos = GetBoundingBoxPosition(boundingBox2);
    vector boundingBox1Size = GetBoundingBoxLegacySize(boundingBox1);
    vector boundingBox2Size = GetBoundingBoxLegacySize(boundingBox2);
    rotation boundingBox1Rot = GetBoundingBoxRootRotation(boundingBox1);
    rotation boundingBox2Rot = GetBoundingBoxRootRotation(boundingBox2);
     // Calculate half sizes of the bounding boxes
    vector halfSize1 = boundingBox1Size * 0.5;
    vector halfSize2 = boundingBox2Size * 0.5;
    
    // Calculate the rotated half sizes using quaternions
    vector rotatedHalfSize1 = halfSize1 * boundingBox1Rot;
    vector rotatedHalfSize2 = halfSize2 * boundingBox2Rot;
    
    // Calculate the corners of the bounding boxes
    list corners1 = [
        boundingBox1Pos + rotatedHalfSize1,
        boundingBox1Pos + <rotatedHalfSize1.x, -rotatedHalfSize1.y, rotatedHalfSize1.z>,
        boundingBox1Pos + <rotatedHalfSize1.x, rotatedHalfSize1.y, rotatedHalfSize1.z>,
        boundingBox1Pos + <rotatedHalfSize1.x, -rotatedHalfSize1.y, -rotatedHalfSize1.z>,
        boundingBox1Pos - rotatedHalfSize1,
        boundingBox1Pos + <-rotatedHalfSize1.x, rotatedHalfSize1.y, -rotatedHalfSize1.z>,
        boundingBox1Pos + <-rotatedHalfSize1.x, -rotatedHalfSize1.y, -rotatedHalfSize1.z>,
        boundingBox1Pos + <-rotatedHalfSize1.x, rotatedHalfSize1.y, rotatedHalfSize1.z>
    ];
    
    list corners2 = [
        boundingBox2Pos + rotatedHalfSize2,
        boundingBox2Pos + <rotatedHalfSize2.x, -rotatedHalfSize2.y, rotatedHalfSize2.z>,
        boundingBox2Pos + <rotatedHalfSize2.x, rotatedHalfSize2.y, rotatedHalfSize2.z>,
        boundingBox2Pos + <rotatedHalfSize2.x, -rotatedHalfSize2.y, -rotatedHalfSize2.z>,
        boundingBox2Pos - rotatedHalfSize2,
        boundingBox2Pos + <-rotatedHalfSize2.x, rotatedHalfSize2.y, -rotatedHalfSize2.z>,
        boundingBox2Pos + <-rotatedHalfSize2.x, -rotatedHalfSize2.y, -rotatedHalfSize2.z>,
        boundingBox2Pos + <-rotatedHalfSize2.x, rotatedHalfSize2.y, rotatedHalfSize2.z>
    ];
    
    vector corner20 = llList2Vector(corners2, 0);
    vector corner27 = llList2Vector(corners2, 0);
    integer i;
    // Check for intersection using AABB-AABB collision detection
    for (i = 0; i < 8; ++i) {
        vector corner1 = llList2Vector(corners1, i);
        vector corner2 = llList2Vector(corners2, i);
        if (corner1.x > corner2.x || corner1.x < corner2.x) jump continue;
        if (corner1.y > corner2.y || corner1.y < corner2.y) jump continue;
        if (corner1.z > corner2.z || corner1.z < corner2.z) jump continue;
        
        return TRUE; // Bounding boxes intersect
        @continue;
    }
    
    return FALSE; // Bounding boxes do not intersect
}

// returns [size, pos] of the object
list GetMultiBox(list objectIds)
{
    vector min;
    vector max;
    int i = 0;
    while(i < llGetListLength(objectIds))
    {
        key objectId = llList2Key(objectIds, i++);
        list l = llGetBoundingBox(objectId);
        if (llGetListLength(l) > 0)
        {
            vector pos = GetObjectPos(objectId);
            
            vector oMin = llList2Vector(l, 0)+pos;
            vector oMax = llList2Vector(l, 1)+pos;
            
            if (i == 1)
            {
                min = oMin;
                max = oMax;
            }
            else
            {
                min.x = Min(min.x, oMin.x);
                min.y = Min(min.y, oMin.y);
                min.z = Min(min.z, oMin.z);
                max.x = Max(max.x, oMax.x);
                max.y = Max(max.y, oMax.y);
                max.z = Max(max.z, oMax.z);
            }
        }
    }
    vector size = <max.x-min.x, max.y-min.y, max.z-min.z>+<1,1,0>;
    return [size, min-<.5,.5,0>+size/2];
}

bool IsInBoundingBox(vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);
    
    vector diff = bbPos - pos;
    vector flattenedDiff = diff/bbRot;
    
    vector boxRadius = bbSize*.5;

    return flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z;
}

// returns the distance of a ray intersecting a plane
// returns -1 if there is no intersection
float PlaneRayIntersectDistance(vector planeNormal, float distance, vector rayOrigin, vector rayDirection)
{
    float directionDotProduct = planeNormal * rayDirection;
    if (directionDotProduct == 0)
    {
        return -1;
    }

    return (planeNormal * rayOrigin + distance) / directionDotProduct;
}

// Function to calculate the closest distance from a point to a plane
float GetDistanceToPlane(vector planeNormal, vector planePosition, vector pointPosition)
{
    // Calculate the distance vector from the plane position to the point
    vector pointToPlane = pointPosition - planePosition;

    // the dot product of the plane's normal vector and the pointToPlane vector negated (the negative sign is applied). This represents the signed distance from the point to the plane.
    float sn = -(planeNormal * pointToPlane);
    // the dot product of the plane's normal vector with itself, which is essentially the squared magnitude of the normal vector.
    float sd = (planeNormal * planeNormal);
    // the ratio of sn to sd. This calculates the perpendicular distance from the point to the plane as a fraction of the squared magnitude of the normal vector.
    float sb = sn / sd;

    vector result = pointPosition + sb * planeNormal;
    return llVecDist(pointPosition, result);
}

// returns the smaller number, if a number is negative, the other number is used
float MinNonNegative(float f1, float f2)
{
    if (f1 < 0)
    {
        return f2;
    }
    if (f2 < 0)
    {
        return f1;
    }

    if (f1 < f2)
    {
        return f1;
    }
    return f2;
}

#define OUT_OF_BOUNDS_HEIGHT -1337
// returns the height of a position in a bounding box to the "outside" straight up
float GetBoundingBoxSurfaceHeightFromOnlyInside(vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);

    vector up = llRot2Up(bbRot);
    if (up.z < 0)
    {
        bbRot = llEuler2Rot(<0, PI, 0>) * bbRot;
    }
    
    vector diff = bbPos - pos;
    vector flattenedDiff = diff/bbRot;

    vector boxRadius = bbSize*.5;
    vector rotatedRadius = <boxRadius.x,0,0>*bbRot;

    bool isInBounds = (flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z);

    if (!isInBounds)
    {
        return OUT_OF_BOUNDS_HEIGHT;
    }

    float distance = PlaneRayIntersectDistance(<1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    distance = MinNonNegative(distance, PlaneRayIntersectDistance(<-1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>));
    distance = MinNonNegative(distance, PlaneRayIntersectDistance(<0, 1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    distance = MinNonNegative(distance, PlaneRayIntersectDistance(<0, -1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    distance = MinNonNegative(distance, PlaneRayIntersectDistance(<0, 0, 1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    return distance;
}

// returns the height of a position in a bounding box to the "outside" straight up
float GetBoundingBoxSurfaceHeight(vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);

    vector diff = bbPos - pos;
    vector flattenedDiff = diff/bbRot;

    vector boxRadius = bbSize*.5;

    bool isInBounds = (flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z);

    if (!isInBounds)
    {
        return OUT_OF_BOUNDS_HEIGHT;
    }

    float upDistance =                      PlaneRayIntersectDistance(< 1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<-1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0,  1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, -1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0,  1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0, -1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    return upDistance;
}

// returns the height of a position in a bounding box to the "outside" straight up
float GetBoundingBoxSurfaceHeight_Debug(int link, vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);

    vector diff = bbPos - pos;

    vector flattenedDiff = diff/bbRot;

    vector boxRadius = bbSize*.5;

    bool isInBounds = (flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z);

    if (!isInBounds)
    {
        SetLinkText(link, "OOB");
        return OUT_OF_BOUNDS_HEIGHT;
    }

    float distance2Front = PlaneRayIntersectDistance(< 1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    float distance2Back =  PlaneRayIntersectDistance(<-1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    float distance2Left =  PlaneRayIntersectDistance(< 0, 1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>);
    float distance2Right = PlaneRayIntersectDistance(< 0,-1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>);
    float distance2Up =    PlaneRayIntersectDistance(< 0, 0, 1> * bbRot, boxRadius.z, diff, <0, 0, 1>);
    float distance2Down =  PlaneRayIntersectDistance(< 0, 0,-1> * bbRot, boxRadius.z, diff, <0, 0, 1>);

    SetLinkText(link, 
        "distance2Front: "+(string)distance2Front+
        "\ndistance2Back: "+(string)distance2Back+
        "\ndistance2Left: "+(string)distance2Left+
        "\ndistance2Right: "+(string)distance2Right+
        "\ndistance2Up: "+(string)distance2Up+
        "\ndistance2Down: "+(string)distance2Down
    );
    float upDistance =                      PlaneRayIntersectDistance(< 1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<-1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0,  1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, -1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0,  1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0, -1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    return upDistance;
}

// returns the height of a position in a bounding box to the "outside" straight up
float GetClosestBoundingBoxPlaneDistanceFromInside(vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);

    vector diff = bbPos - pos;

    vector flattenedDiff = diff/bbRot;

    vector boxRadius = bbSize*.5;

    bool isInBounds = (flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z);

    if (!isInBounds)
    {
        return OUT_OF_BOUNDS_HEIGHT;
    }

    vector up = llRot2Up(bbRot);
    vector left = llRot2Left(bbRot);
    vector fwd = llRot2Fwd(bbRot);

    //float GetDistanceToPlane(vector planeNormal, vector planePosition, vector point)
    float distance2Up =    GetDistanceToPlane(<  0,  0,  1> * bbRot,    up * bbSize.z/2, -diff);
    float distance2Down =  GetDistanceToPlane(<  0,  0, -1> * bbRot,   -up * bbSize.z/2, -diff);
    float distance2Left =  GetDistanceToPlane(<  0,  1,  0> * bbRot,  left * bbSize.y/2, -diff);
    float distance2Right = GetDistanceToPlane(<  0, -1,  0> * bbRot, -left * bbSize.y/2, -diff);
    float distance2Front = GetDistanceToPlane(<  1,  0,  0> * bbRot,   fwd * bbSize.x/2, -diff);
    float distance2Back =  GetDistanceToPlane(< -1,  0,  0> * bbRot,  -fwd * bbSize.x/2, -diff);

    float closestDistance = distance2Up;

    closestDistance = MinFloat(distance2Down, closestDistance);
    closestDistance = MinFloat(distance2Left, closestDistance);
    closestDistance = MinFloat(distance2Right, closestDistance);
    closestDistance = MinFloat(distance2Front, closestDistance);
    closestDistance = MinFloat(distance2Back, closestDistance);
    
    return closestDistance;
}

// returns the height of a position in a bounding box to the "outside" straight up
float GetClosestBoundingBoxPlaneDistanceFromInside_Debug(int link, vector pos, BoundingBoxData boundingBoxData)
{
    vector bbSize = GetBoundingBoxSize(boundingBoxData);
    vector bbPos = GetBoundingBoxPosition(boundingBoxData);
    rotation bbRot = GetBoundingBoxRotation(boundingBoxData);

    vector diff = bbPos - pos;

    vector flattenedDiff = diff/bbRot;

    vector boxRadius = bbSize*.5;

    bool isInBounds = (flattenedDiff.x < boxRadius.x
        && flattenedDiff.x > -boxRadius.x
        && flattenedDiff.y < boxRadius.y
        && flattenedDiff.y > -boxRadius.y
        && flattenedDiff.z < boxRadius.z
        && flattenedDiff.z > -boxRadius.z);

    if (!isInBounds)
    {
        SetLinkText(link, "OOB");
        return OUT_OF_BOUNDS_HEIGHT;
    }

    vector up = llRot2Up(bbRot);
    vector left = llRot2Left(bbRot);
    vector fwd = llRot2Fwd(bbRot);

    //float GetDistanceToPlane(vector planeNormal, vector planePosition, vector point)
    float distance2Up =    GetDistanceToPlane(<  0,  0,  1> * bbRot,    up * bbSize.z/2, -diff);
    float distance2Down =  GetDistanceToPlane(<  0,  0, -1> * bbRot,   -up * bbSize.z/2, -diff);
    float distance2Left =  GetDistanceToPlane(<  0,  1,  0> * bbRot,  left * bbSize.y/2, -diff);
    float distance2Right = GetDistanceToPlane(<  0, -1,  0> * bbRot, -left * bbSize.y/2, -diff);
    float distance2Front = GetDistanceToPlane(<  1,  0,  0> * bbRot,   fwd * bbSize.x/2, -diff);
    float distance2Back =  GetDistanceToPlane(< -1,  0,  0> * bbRot,  -fwd * bbSize.x/2, -diff);
    float closestDistance = distance2Up;
    closestDistance = MinFloat(distance2Down, closestDistance);
    closestDistance = MinFloat(distance2Left, closestDistance);
    closestDistance = MinFloat(distance2Right, closestDistance);
    closestDistance = MinFloat(distance2Front, closestDistance);
    closestDistance = MinFloat(distance2Back, closestDistance);
    llSetLinkPrimitiveParamsFast(1, [
        PRIM_TEXT, "closestDistance: "+(string)closestDistance+"\ndistance2Front: "+(string)distance2Front+
            "\ndistance2Back: "+(string)distance2Back+
            "\ndistance2Left: "+(string)distance2Left+
            "\ndistance2Right: "+(string)distance2Right+
            "\ndistance2Up: "+(string)distance2Up+
            "\ndistance2Down: "+(string)distance2Down, <1,1,1>,1,
        PRIM_LINK_TARGET, 2, PRIM_COLOR, ALL_SIDES, <0, 0, 1>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Up,    PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, <  0,  0,  1>*bbRot)/llGetRootRotation(),
        PRIM_LINK_TARGET, 3, PRIM_COLOR, ALL_SIDES, <0, 0, 1>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Down,  PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, <  0,  0, -1>*bbRot)/llGetRootRotation(),
        PRIM_LINK_TARGET, 4, PRIM_COLOR, ALL_SIDES, <0, 1, 0>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Left,  PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, <  0,  1,  0>*bbRot)/llGetRootRotation(),
        PRIM_LINK_TARGET, 5, PRIM_COLOR, ALL_SIDES, <0, 1, 0>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Right, PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, <  0, -1,  0>*bbRot)/llGetRootRotation(),
        PRIM_LINK_TARGET, 6, PRIM_COLOR, ALL_SIDES, <1, 0, 0>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Front, PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, <  1,  0,  0>*bbRot)/llGetRootRotation(),
        PRIM_LINK_TARGET, 7, PRIM_COLOR, ALL_SIDES, <1, 0, 0>, 1, PRIM_POS_LOCAL, <0,0,0>, PRIM_SIZE, <.2,.2,2>*distance2Back,  PRIM_ROT_LOCAL, llRotBetween(<0,0,1>, < -1,  0,  0>*bbRot)/llGetRootRotation()
    ]);

    float upDistance =                      PlaneRayIntersectDistance(< 1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>);
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<-1, 0, 0> * bbRot, boxRadius.x, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0,  1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, -1, 0> * bbRot, boxRadius.y, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0,  1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    upDistance = MinNonNegative(upDistance, PlaneRayIntersectDistance(<0, 0, -1> * bbRot, boxRadius.z, diff, <0, 0, 1>));
    return upDistance;
}

#define TOP 1
#define BOTTOM 2
#define LEFT 3
#define RIGHT 4
#define FRONT 5
#define BACK 6

#define GetUpNormalForFlatSideBb(boundingBoxData) GetUpNormalForFlatSideBb(GetBoundingBoxSize(boundingBoxData), GetBoundingBoxRotation(boundingBoxData))

vector GetUpNormalForFlatSide(vector size, rotation rot)
{
    if (size.x<=size.y && size.x<size.z)
    {
        vector fwd = llRot2Fwd(rot);
        if (fwd.z > 0)
        {
            return fwd;
        }
        return -fwd;
    }
    if (size.y<size.x && size.y<size.z)
    {
        vector fwd = llRot2Left(rot);
        if (fwd.z > 0)
        {
            return fwd;
        }
        return -fwd;
    }
    //if (size.z<=size.y && size.z<=size.x)
    {
        vector fwd = llRot2Up(rot);
        if (fwd.z > 0)
        {
            return fwd;
        }
        return -fwd;
    }
}
vector GetClosestDirectionToFlatSideFromPosition(vector position, vector size)
{
    if (size.x <= size.y && size.x <= size.z)
    {
        vector diff = position - <size.x/2, 0, 0>;
        return llVecNorm(diff);
        vector diff2 = position + <size.x/2, 0, 0>;

        return llVecNorm(ConditionalReturnVector(llVecMag(diff) < llVecMag(diff2), diff, diff2));
    }
    if (size.y <= size.x && size.y <= size.z)
    {
        vector diff = position - <0, size.y/2, 0>;
        return llVecNorm(diff);
        vector diff2 = position + <0, size.y/2, 0>;
        return llVecNorm(ConditionalReturnVector(llVecMag(diff) < llVecMag(diff2), diff, diff2));
        return llVecNorm(diff);
    }
    //if (size.z <= size.y && size.z <= size.x)
    {
        vector diff = position - <0, 0, size.z/2>;
        return llVecNorm(diff);
        vector diff2 = position + <0, 0, size.z/2>;
        return llVecNorm(ConditionalReturnVector(llVecMag(diff) < llVecMag(diff2), diff, diff2));
        return llVecNorm(diff);
    }
}
vector GetUpNormal(rotation rot)
{
}

vector GetSmallestVector(list items)
{
    int i = llGetListLength(items);

    vector smallest = llList2Vector(items, --i);
    while (i > 0)
    {
        vector c = llList2Vector(items, --i);

        if (llVecMag(c) < llVecMag(smallest))
        {
            smallest = c;
        }
    }
    return smallest;
}

/*list GetCloserUpFrom(rotation rot, list flatSides)
{
    vector size = GetBoundingBoxSize(boundingBoxData);

    vector closestVector = <2, 0, 0>;
    list vectDists = [];
    int i = llGetListLength(flatSides);
    while (i > 0)
    {
        vector compareVector = llList2Vector(flatSides, i);
        float closestDist = llVecMag(closestVector);
        vector testVector = llRot2Up(rot) ;

        if (closestDist > llVecMag())
    }

    GetSmallestVector(llRot2Up(rot)-)

    if (size.x<size.y && size.x<size.z)
    {
        return [<1, 0, 0>, <-1, 0, 0>];
    }
    if (size.y<size.x && size.y<size.z)
    {
        return [<0, 1, 0>, <0, -1, 0>];
    }
    //if (size.z<size.y && size.z<size.x)
    {
        return [<0, 0, 1>, <0, 0, -1>];
    }
}*/
