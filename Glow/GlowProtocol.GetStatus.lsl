// key of the target owner
// can be NULL_KEY to ask anyone
#define GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET 0
#define GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET_DEFAULT NULL_KEY

#define GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET 0
#define GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET_DEFAULT NULL_KEY
// a list of colors/vectors, first param is the count
#define GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_COLORS 1

list GetAllParamsFromGetStatusMessage(list tokenizedMessage)
{
    list desiredParams = [GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET];
    
    key target = GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET_DEFAULT;

    // skipping first param which is GLOW_PROTOCOL_COMMAND_TYPE
    int i = 1;
    int messagePartsCount = llGetListLength(tokenizedMessage);
    
    while (i < messagePartsCount)
    {
        int part = (int)llList2String(tokenizedMessage, i++);

        if (part == GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET)
        {
            target = (key)llList2String(tokenizedMessage, i++);
        }
        else
        {
            // unknown in this version
        }
    }

    if (target == "")
    {
        target = GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET_DEFAULT;
    }

    list ret = [];
    i = 0;
    while (i < llGetListLength(desiredParams))
    {
        int desiredParam = llList2Integer(desiredParams, i++);
        
        if (desiredParam == GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET)
        {
            ret += target;
        }
        else
        {
            // unknown
        }
    }

    return ret;
}

/// Returns [ TargetKey, color1, color2, ... ]
list GetParamsFromGetStatusResponseMessage(list tokenizedMessage)
{
    list desiredParams = [GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET];
    
    key target = GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET_DEFAULT;
    list colors = [];

    // skipping first param which is GLOW_PROTOCOL_COMMAND_TYPE
    int i = 1;
    int messagePartsCount = llGetListLength(tokenizedMessage);
    
    while (i < messagePartsCount)
    {
        int part = (int)llList2String(tokenizedMessage, i++);

        if (part == GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET)
        {
            target = (key)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_COLORS)
        {
            int colorCount = (int)llList2String(tokenizedMessage, i++);
            while (colorCount--)
            {
                colors += (vector)llList2String(tokenizedMessage, i++);
            }
        }
        else
        {
            // unknown in this version
        }
    }

    if (target == "")
    {
        target = GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_KEY_TARGET_DEFAULT;
    }

    return [target] + colors;
}

/// <summary>
/// creates a message that can be parsed back by GetAllParamsFromGlowMessage again
/// </summary>
#define GetGlowStatusMessage(target) llList2CSV(\
    [GLOW_PROTOCOL_COMMAND_TYPE_GET_STATUS]\
    + ConditionalReturnList(target != GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET, target], []))

/// <summary>
/// creates a message that can be parsed back by GetAllParamsFromGlowMessage again
/// </summary>
#define GetGlowStatusResponseMessage(target) llList2CSV(\
    [GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND]\
    + ConditionalReturnList(target != GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET, target], [])\
    + [GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND_COLORS, llGetListLength(GlowColors)]\
    + GlowColors)
