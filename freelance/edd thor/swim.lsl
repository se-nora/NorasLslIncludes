// Note: this is an inofficial replication of the include file, since I could not find it anywhere

#define POOL_CHAN 423789
#define SURFACE_HOVER_ALLOWANCE .1

#define ENTER_POOL_MSG "enter_pool"
#define EXIT_POOL_MSG "exit_pool"

list bbInfo(key id)
{
    list l = llGetBoundingBox(id);
    vector min = llList2Vector(l, 0);
    vector max = llList2Vector(l, 1);
    vector bbSize = <max.x-min.x, max.y-min.y, max.z-min.z>;
    l = llGetObjectDetails(id, [OBJECT_POS, OBJECT_ROT]);
    vector offset = (min+max)/2.0; 
    offset *= llList2Rot(l, 1);
    vector center = llList2Vector(l, 0) + (offset * llList2Rot(l, 0)); 
    rotation rot = llList2Rot(l, 1);
    return [center, rot, bbSize];
}
 
integer gBXx(vector A, vector Bo, vector Bs, rotation Br)
{
    vector eB = 0.5*Bs;
    vector rA = (A-Bo)/Br;

    return rA.x < eB.x
        && rA.x > -eB.x
        && rA.y < eB.y
        && rA.y > -eB.y
        && rA.z < eB.z
        && rA.z > -eB.z;
}