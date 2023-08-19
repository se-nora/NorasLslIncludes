// Function to check if two spheres intersect
bool Intersects(vector sphere1Pos, float sphere1Radius, vector sphere2Pos, float sphere2Radius)
{
    // Calculate the distance between the centers of the spheres
    float distance = llVecDist(sphere1Pos, sphere2Pos);
    
    // Calculate the sum of the radii
    float sumRadii = sphere1Radius + sphere2Radius;
    
    // If the distance between the centers is less than or equal to the sum of the radii, they intersect
    if (distance <= sumRadii) {
        return true; // Spheres intersect
    } else {
        return false; // Spheres do not intersect
    }
}
