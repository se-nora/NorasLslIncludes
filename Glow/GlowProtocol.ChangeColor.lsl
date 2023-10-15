// key of the target owner
// can be NULL_KEY if it affects all
#define GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET 0
#define GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET_DEFAULT NULL_KEY
#define GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR 1
#define GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR_DEFAULT <0,0,0>

/// <summary>
/// parses the message and returns a list with the parsed glow params.
/// if a param is missing from the message, then the default value for that param will be returned
/// the param list is ordered like so:
//  [
//      GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET,
//      GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR,
//  ]
/// this means you can get the corresponding param by using the GLOW_PROTOCOL_GLOW_COMMAND_ definition as a llList2X(params, offset) offset
/// </summary>
/// <example>
/// listen (int channel, string sender, key senderKey, string message)
/// {
///     list glowParams = GetAllParamsFromGlowMessage(message);
/// 
///     key target = llList2Key(glowParams, GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET);
///     vector glowColor = (vector)llList2String(glowParams, GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR);
/// }
/// </example>
list GetAllParamsFromChangeColorMessage(list tokenizedMessage)
{
    return GetParamsFromChangeColorMessage(tokenizedMessage, [
        GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET,
        GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR
    ]);
}

list GetParamsFromChangeColorMessage(list tokenizedMessage, list desiredParams)
{
    key target = GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET_DEFAULT;
    vector color = GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR_DEFAULT;

    // skipping first param which is GLOW_PROTOCOL_COMMAND_TYPE
    int i = 1;
    int messagePartsCount = llGetListLength(tokenizedMessage);
    
    while (i < messagePartsCount)
    {
        int part = (int)llList2String(tokenizedMessage, i++);

        if (part == GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET)
        {
            target = (key)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR)
        {
            color = (vector)llList2String(tokenizedMessage, i++);
        }
        else
        {
            // unknown in this version
        }
    }

    list ret = [];
    i = 0;
    while (i < llGetListLength(desiredParams))
    {
        int desiredParam = llList2Integer(desiredParams, i++);
        
        if (desiredParam == GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET)
        {
            ret += target;
        }
        else if (desiredParam == GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR)
        {
            ret += color;
        }
        else
        {
            // unknown
        }
    }

    return ret;
}

/// <summary>
/// creates a message that can be parsed back by GetAllParamsFromGlowMessage again
/// </summary>
string CreateChangeColorMessage(key target, vector color)
{
    return llList2CSV(
        [GLOW_PROTOCOL_COMMAND_TYPE_CHANGE_COLOR]
        + ConditionalReturnList(target != GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET, target], [])
        + ConditionalReturnList(color != GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR_DEFAULT, [GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR, color], []));
}
