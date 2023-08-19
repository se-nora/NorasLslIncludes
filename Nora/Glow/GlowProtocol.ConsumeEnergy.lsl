// key of the target owner
// can be NULL_KEY if it affects all
#define GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET 0
#define GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET_DEFAULT NULL_KEY
#define GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN 1
#define GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN_DEFAULT 10

/// <summary>
/// parses the message and returns a list with the parsed glow params.
/// if a param is missing from the message, then the default value for that param will be returned
/// the param list is ordered like so:
//  [
//      GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET,
//      GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN
//  ]
/// this means you can get the corresponding param by using the GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ definition as a llList2X(params, offset) offset
/// </summary>
/// <example>
/// listen (int channel, string sender, key senderKey, string message)
/// {
///     list glowParams = GetAllParamsFromConsumeEnergyMessage(GetTokenizedGlowProtocolMessage(message));
/// 
///     float consumedEnergy = llList2Float(glowParams, GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN);
/// }
/// </example>
#define GetAllParamsFromConsumeEnergyMessage(tokenizedMessage) GetParamsFromConsumeEnergyMessage(tokenizedMessage, [\
    GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET,\
    GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN\
])

list GetParamsFromConsumeEnergyMessage(list tokenizedMessage, list desiredParams)
{
    key target = GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET_DEFAULT;
    float energyDrain = GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN_DEFAULT;

    // skipping first param which is GLOW_PROTOCOL_COMMAND_TYPE
    int i = 1;
    int messagePartsCount = llGetListLength(tokenizedMessage);
    
    while (i < messagePartsCount)
    {
        int part = (int)llList2String(tokenizedMessage, i++);

        if (part == GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET)
        {
            target = (key)llList2String(tokenizedMessage, i++);
        }
        else if (part == GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN)
        {
            energyDrain = (float)llList2String(tokenizedMessage, i++);
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
        
        if (desiredParam == GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET)
        {
            ret += target;
        }
        else if (desiredParam == GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN)
        {
            ret += energyDrain;
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
#define CreateConsumeEnergyMessage(target, consumedEnergy) llList2CSV(\
    [GLOW_PROTOCOL_COMMAND_TYPE_CONSUME_ENERGY]\
    + ConditionalReturnList(target != GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET_DEFAULT, [GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_KEY_TARGET, target], [])\
    + ConditionalReturnList(consumedEnergy != GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN_DEFAULT, [GLOW_PROTOCOL_CONSUME_ENERGY_COMMAND_ENERGY_DRAIN, consumedEnergy], []))