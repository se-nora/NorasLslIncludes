#define ENTER_POOL_MSG "enter_pool"
#define EXIT_POOL_MSG "exit_pool"
#define HELLO_POOL_MSG "hello_pool"
#define POOL_CHANNEL 423789

// Key of pool water object.
key PoolId = NULL_KEY;

#define GetPoolForce(boundingBoxData) (vector)GetBoundingBoxObjectDescription(boundingBoxData)

// returns [center, rot, size, root_rotation, objectDesc, legacySize] of the object
BoundingBoxData GetPoolBoundingBox(key poolId)
{
    if (poolId == NULL_KEY)
    {
        // we simply say the sim water is a pool
        return [
            <128, 128, llWater(ZERO_VECTOR)/2>,
            ZERO_ROTATION,
            <256, 256, llWater(ZERO_VECTOR)>,
            ZERO_ROTATION,
            <0,0,0>,
            <128, 128, llWater(ZERO_VECTOR)/2>
        ];
    }

    return GetBoundingBoxData(poolId);
}
