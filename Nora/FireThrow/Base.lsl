#define FIRE_MAGIC_CHANNEL -323513
#define FIRE_MAGIC_TARGET_ALL "All"
#define FIRE_MAGIC_PROTOCOL_GETSTATUS_MESSAGE 1
#define FIRE_MAGIC_PROTOCOL_GETSTATUS_MESSAGE_CMD FIRE_MAGIC_PROTOCOL_GETSTATUS_MESSAGE

#define FIRE_MAGIC_PROTOCOL_FIRESTATUS_MESSAGE 2, IsFireMagicFireable, FireMagicColor, FireMagicEndColor
#define FIRE_MAGIC_PROTOCOL_FIRESTATUS_MESSAGE_CMD PPFirstParam(FIRE_MAGIC_PROTOCOL_FIRESTATUS_MESSAGE)
#define SendFireStatusMessage(target) llRegionSay(FIRE_MAGIC_CHANNEL, llList2CSV([FIRE_MAGIC_PROTOCOL_FIRESTATUS_MESSAGE, target]))
TakeParamsFromFireStatusMessage(list data)
{
    string target = llList2String(data, 4);
    if (target != FIRE_MAGIC_TARGET_ALL && target != WhoAmI)
    {
        return;
    }
    IsFireMagicFireable = (bool)llList2String(data, 1);
    FireMagicColor = (vector)llList2String(data, 2);
    FireMagicEndColor = (vector)llList2String(data, 3);
}
// a string to know which fire to enable/disable, it is usually read from the description
string WhoAmI;

//#define FIRE_MAGIC_PROTOCOL_FIRE_DETACHED_MESSAGE 3

#define FIRE_MAGIC_PROTOCOL_FIRE_THROW_STATUS_MESSAGE 5, IsFireMagicFiring, IsFireMagicFiring, IsFireMagicHolding, IsFireMagicHoldParticlesEnabled
#define FIRE_MAGIC_PROTOCOL_FIRE_THROW_STATUS_MESSAGE_CMD PPFirstParam(FIRE_MAGIC_PROTOCOL_FIRE_THROW_STATUS_MESSAGE)
#define SendFireThrowStatusMessage() llRegionSay(FIRE_MAGIC_CHANNEL, llList2CSV([FIRE_MAGIC_PROTOCOL_FIRE_THROW_STATUS_MESSAGE]))
TakeParamsFromFireThrowStatusMessage(list data)
{
    IsFireMagicFiring = (bool)llList2String(data, 1);
    IsFireMagicFireable = (bool)llList2String(data, 2);
    IsFireMagicHolding = (bool)llList2String(data, 3);
    IsFireMagicHoldParticlesEnabled = (bool)llList2String(data, 4);
}

vector FireMagicColor = <.6,.4,0>;
vector FireMagicEndColor = <0.7, 0.51059, 0>;

bool IsFireMagicFireable;
bool IsFireMagicFiring;
bool IsFireMagicHolding;
bool IsFireMagicHoldParticlesEnabled;

