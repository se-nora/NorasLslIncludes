#include "Nora\Nora.lsl"

// returns 0 for female and 1 for male
#define GetGender(k) (int)(.5+llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0))

// returns a value between 0 (feminine) and 1 (masculine)
#define GetMasculinity(k) llList2Float(llGetObjectDetails(k, [OBJECT_BODY_SHAPE_TYPE]), 0)

#define IsAvatar(k) (k != NULL_KEY && llGetOwnerKey(k) == k)
