// returns 0 for female and 1 for male
#define GetGender(k) (int)(.5+llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0))

// returns a value between -1 (feminine) and 1 (masculine)
#define GetMasculinity(k) (2*llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0)-1)
// returns a value between -1 (masculine) and 1 (feminine)
#define GetFemininity(k) -GetMasculinity(k)

#define IsAvatar(k) (k != NULL_KEY && llGetOwnerKey(k) == k)
