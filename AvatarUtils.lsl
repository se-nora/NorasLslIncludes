// returns 0 for female and 1 for male
#define GetGender(k) (int)(.5+llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0))

// returns a value between -1 (feminine) and 1 (masculine)
#define GetMasculinity(k) (2*llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0)-1)
// returns a value between -1 (masculine) and 1 (feminine)
#define GetFemininity(k) -GetMasculinity(k)

#define IsAvatar(k) (k != NULL_KEY && llGetOwnerKey(k) == k)

key GetAvatarGroupKey(key avatar)
{
    // This assumes they have at least one attachment, which is a pretty safe assumption these days.
    // If they don't have any attachments, or if they're out of region, NULL_KEY is returned.
    if (llGetAgentSize(avatar) == ZERO_VECTOR)
    {
        return NULL_KEY;
    }
    key k = llList2Key(llGetObjectDetails(llList2Key(llGetAttachedList(avatar), 0), [OBJECT_GROUP]), 0);
    if (k == "")
    {
        return NULL_KEY;
    }

    return k; // We do this because zero attachments will return "" for group key.
}