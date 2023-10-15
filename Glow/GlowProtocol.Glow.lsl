// key of the target owner
// can be NULL_KEY if it affects all
#define GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET 0
#define GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET_DEFAULT NULL_KEY
#define GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH 1
#define GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH_DEFAULT 1
#define GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED 2
#define GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT .2
#define GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION 3
#define GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT .1
#define GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED 4
#define GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED_DEFAULT 0

/// <summary>
/// parses the message and returns a list with the parsed glow params.
/// if a param is missing from the message, then the default value for that param will be returned
/// the param list is ordered like so:
//  [
//      GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET,
//      GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH,
//      GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED,
//      GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION
//  ]
/// this means you can get the corresponding param by using the GLOW_PROTOCOL_GLOW_COMMAND_ definition as a llList2X(params, offset) offset
/// </summary>
/// <example>
/// listen (int channel, string sender, key senderKey, string message)
/// {
///     list glowParams = GetAllParamsFromGlowMessage(message);
/// 
///     key target = llList2Key(glowParams, GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET);
///     float glowStrength = llList2Float(glowParams, GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH);
///     float fadeSpeed = llList2Float(glowParams, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED);
///     float timerDuration = llList2Float(glowParams, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION);
/// }
/// </example>
list GetAllParamsFromGlowMessage(list tokenizedMessage)
{
    return GetParamsFromGlowMessage(tokenizedMessage, [
        GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET,
        GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH,
        GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED,
        GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION,
        GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED
    ]);
}

list GetParamsFromGlowMessage(list tokenizedMessage, list desiredParams)
{
    key target = GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET_DEFAULT;
    float glowStrength = GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH_DEFAULT;
    float fadeSpeed = GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT;
    float timerDuration = GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT;
    bool isForced = GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED_DEFAULT;

    // skipping first param which is GLOW_PROTOCOL_COMMAND_TYPE
    int i = 1;
    int messagePartsCount = llGetListLength(tokenizedMessage);
    
    while (i < messagePartsCount)
    {
        int part = (int)llList2String(tokenizedMessage, i++);

        if (part == GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET)
        {
            target = (key)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH)
        {
            glowStrength = (float)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED)
        {
            fadeSpeed = (float)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION)
        {
            timerDuration = (float)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED)
        {
            isForced = (bool)llList2String(tokenizedMessage, i++);
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
        
        if (desiredParam == GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET)
        {
            ret += target;
        }
        else if (desiredParam == GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH)
        {
            ret += glowStrength;
        }
        else if (desiredParam == GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED)
        {
            ret += fadeSpeed;
        }
        else if (desiredParam == GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION)
        {
            ret += timerDuration;
        }
        else if (desiredParam == GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED)
        {
            ret += isForced;
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
string CreateGlowMessageDefault(key target, float strength)
{
    return llList2CSV(
        [GLOW_PROTOCOL_COMMAND_TYPE_GLOW]
        + ConditionalReturnList(target != GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET, target], [])
        + ConditionalReturnList(strength != GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH, strength], []));
}

/// <summary>
/// creates a message that can be parsed back by GetAllParamsFromGlowMessage again
/// </summary>
string CreateGlowMessage(key target, float strength, float fadeSpeed, float timerDuration, bool isForced)
{
    return llList2CSV(
        [GLOW_PROTOCOL_COMMAND_TYPE_GLOW]
        + ConditionalReturnList(target != GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET, target], [])
        + ConditionalReturnList(strength != GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH, strength], [])
        + ConditionalReturnList(fadeSpeed != GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED, fadeSpeed], [])
        + ConditionalReturnList(timerDuration != GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION, timerDuration], [])
        + ConditionalReturnList(isForced != GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED_DEFAULT, [GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED, isForced], []));
}
