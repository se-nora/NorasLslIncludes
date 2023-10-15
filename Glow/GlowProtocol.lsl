#define GLOW_CHANNEL -123513

// empty means disabled / all
list RemoteOwnerWhitelist = [];
list RemoteOwnerBlacklist = [];

// command type, default is glow command
#define GLOW_PROTOCOL_COMMAND_TYPE 0
#define GLOW_PROTOCOL_COMMAND_TYPE_GLOW 1
#define GLOW_PROTOCOL_COMMAND_TYPE_CONSUME_ENERGY 2
#define GLOW_PROTOCOL_COMMAND_TYPE_GET_STATUS 3
#define GLOW_PROTOCOL_COMMAND_TYPE_CHANGE_COLOR 4
#define GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND 5

#define GetTokenizedGlowProtocolMessage(message) llCSV2List(message)

bool IsKeyOnBlackList(key k)
{
    return llListFindList(RemoteOwnerBlacklist, [k]) >= 0;
}

bool IsKeyOnWhiteList(key k)
{
    if (k == llGetOwner())
    {
        return true;
    }
    
    return llListFindList(RemoteOwnerWhitelist, [k]) >= 0;
}

string GetParamFromGlowProtocolMessage(string message, int param)
{
    list messageParts = llCSV2List(message);
    int i = 0;
    int messagePartsCount = llGetListLength(messageParts);
    string paramStr = (string)param;
    
    // we cant use llListFindList here, since the list has a stride of 2
    while (i < messagePartsCount)
    {
        if (llList2String(messageParts, i) == paramStr)
            return llList2String(messageParts, i + 1);

        i += 2;
    }

    return "";
}

#include "GlowProtocol.Glow.lsl"
#include "GlowProtocol.GetStatus.lsl"
#include "GlowProtocol.ChangeColor.lsl"
#include "GlowProtocol.ConsumeEnergy.lsl"
