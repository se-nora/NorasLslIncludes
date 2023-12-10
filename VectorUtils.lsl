#include "NumberUtils.lsl"
#ifndef NORA_VECTORUTILS
    #define NORA_VECTORUTILS

    #define VecMult(v1, v2) <v1.x*v2.x, v1.y*v2.y, v1.z*v2.z>
    #define VecAdd(v1, v2) (v1)+(v2)

    vector VecMin(vector v1, vector v2)
    {
        return <MinFloat(v1.x, v2.x), MinFloat(v1.y, v2.y), MinFloat(v1.z, v2.z)>;
    }

    vector VecMax(vector v1, vector v2)
    {
        return <MaxFloat(v1.x, v2.x), MaxFloat(v1.y, v2.y), MaxFloat(v1.z, v2.z)>;
    }

    vector ClampVector(vector v, vector min, vector max)
    {
        return <Clamp(v.x, min.x, max.x), Clamp(v.y, min.y, max.y), Clamp(v.z, min.z, max.z)>;
    }

    vector ClampVec(vector v, vector min, vector max) { return ClampVector(v, min, max); }

    vector VecMaxList(list vectors)
    {
        vector maxVector = llList2Vector(vectors, 0);
        integer numVectors = llGetListLength(vectors);
        integer i = 1;

        for (; i < numVectors; i++)
        {
            vector currentVector = llList2Vector(vectors, i);
            maxVector = VecMax(maxVector, currentVector);
        }

        return maxVector;
    }

    vector VecMinList(list vectors)
    {
        vector maxVector = llList2Vector(vectors, 0);
        integer numVectors = llGetListLength(vectors);
        integer i = 1;

        for (; i < numVectors; i++)
        {
            vector currentVector = llList2Vector(vectors, i);
            maxVector = VecMin(maxVector, currentVector);
        }

        return maxVector;
    }

    vector GetVolume(vector v1)
    {
        return llFabs(v1.x) * llFabs(v1.y) * llFabs(v1.z);
    }

    vector GetNormal(vector p1, vector p2, vector p3)
    {
        vector u = p2 - p1;
        vector v = p3 - p1;
        vector normal = <
            (u.y * v.z) - (u.z * v.y),
            (u.z * v.x) - (u.x * v.z),
            (u.x * v.y) - (u.y * v.x)>;
        return normal;
    }

    rotation RotBetween(vector a, vector b)
    {
        float aabb = llSqrt((a * a) * (b * b)); // product of the lengths of the arguments
        if (aabb)
        {
            float ab = (a * b) / aabb; // normalized dotproduct of the arguments (cosine)
            vector c = <(a.y * b.z - a.z * b.y) / aabb,
                        (a.z * b.x - a.x * b.z) / aabb,
                        (a.x * b.y - a.y * b.x) / aabb >; // normalized crossproduct of the arguments
            float cc = c * c; // squared length of the normalized crossproduct (sine)
            if (cc) // test if the arguments are not (anti)parallel
            {
                float s;
                if (ab > -0.707107)
                    s = 1 + ab; // use the cosine to adjust the s-element
                else 
                    s = cc / (1 + llSqrt(1 - cc)); // use the sine to adjust the s-element
                float m = llSqrt(cc + s * s); // the magnitude of the quaternion
                return <c.x / m, c.y / m, c.z / m, s / m>; // return the normalized quaternion
            }
            if (ab > 0)
            {
                return ZERO_ROTATION; // the arguments are parallel, or anti-parallel if not true:
            }
            float m = llSqrt(a.x * a.x + a.y * a.y); // the length of one argument projected on the XY-plane
            if (m)
            {
                return <a.y / m, -a.x / m, 0, 0>; // return a rotation with the axis in the XY-plane
            }
            return <1, 0, 0, 0>; // the arguments are parallel to the Z-axis, rotate around the X-axis
        }
        return ZERO_ROTATION; // the arguments are too small, return zero rotation
    }
#endif
