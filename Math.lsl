
float GetFillpercentageOfSphere(float fillHeight, float radius)
{
    float volumeFilled = (1.0 / 3.0) * PI * fillHeight * fillHeight * (3.0 * radius - height);
    float totalVolume = (4.0 / 3.0) * PI * radius * radius * radius;

    float percentage = (volumeFilled / totalVolume) * 100.0;
    return percentage;
}
