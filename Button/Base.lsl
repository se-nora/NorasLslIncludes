#define BUTTON_CHANNEL -3164354
#define BUTTON_LINK_CHANNEL 1516513
#define INTERMEDIATE_MEMORY_CHANNEL 342563418

#define OnColor <0, 1, 0>
#define OffColor <1, 0, 0>

bool IsAvatarButtonOn;
bool IsAvatarButtonCharging;
bool IsAvatarDead;
bool HasFallenForward;

float AvatarButtonEnergyLevel = 0;

#define BUTTON_PROTOCOL_STATUS_REQUEST_MESSAGE "status"
#define BUTTON_PROTOCOL_STATUS_MESSAGE ["buttonStatus", IsAvatarButtonOn, AvatarButtonEnergyLevel, IsAvatarButtonCharging]
#define ParseButtonStatusMessage(data) {\
    IsAvatarButtonOn = (bool)llList2String(data, 1);\
    AvatarButtonEnergyLevel = (float)llList2String(data, 2);\
    IsAvatarButtonCharging = (bool)llList2String(data, 3);\
}
#define BUTTON_PROTOCOL_AVATAR_DEATH_STATUS_MESSAGE ["avatarDeadStatus", IsAvatarDead, HasFallenForward]
#define ParseAvatarDeathStatusMessage(data) {\
    IsAvatarDead = (bool)llList2String(data, 1);\
    HasFallenForward = (bool)llList2String(data, 2);\
}
#define SendAvatarDeathStatusMessage() llRegionSay(BUTTON_CHANNEL, llList2CSV(BUTTON_PROTOCOL_AVATAR_DEATH_STATUS_MESSAGE))

#define RequestAvatarButtonStatus() llRegionSay(BUTTON_CHANNEL, BUTTON_PROTOCOL_STATUS_REQUEST_MESSAGE)
#define SendAvatarButtonStatus() llRegionSay(BUTTON_CHANNEL, llList2CSV(BUTTON_PROTOCOL_STATUS_MESSAGE))
