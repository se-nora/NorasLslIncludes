// Color, GlowStrength, DrawRadius, IsFullbright, RainbowPercentage
#define Pen list
#define GetPenColor(pen) llList2Vector(pen, 0)
#define GetPenGlowStrength(pen) llList2Float(pen, 1)
#define GetPenDrawRadius(pen) llList2Float(pen, 2)
#define GetPenIsFullBright(pen) llList2Bool(pen, 3)
#define GetPenRainbowPercentage(pen) llList2Float(pen, 4)

#define CHALK_TEXTURE "62ee1891-ac57-94f9-eb0a-4e3f99f4e698"
#define CHALK_DOTS_TEXTURE "f4e09073-63df-b28c-6593-95b54284f6dc"
#define BLACKBOARD_PEN_COLOR_RAINBOW <-1, -1, -1>
list GetDrawLinePrimitiveParams(vector from, vector to)
{
    int link = 1+(RemainingPrims--);
    list ret = GetDrawLinePrimitiveParamsForLink(link, from, to, false);

    vector tempPartLength = (to-from);
    vector lastFrom = to;
    if (RemainingPrims > 0)
    {
        TemporaryLines = [--link];
        ret += GetDrawLinePrimitiveParamsForLink(link, lastFrom, lastFrom+tempPartLength, true);
        lastFrom+=tempPartLength;
        llSetTimerEvent(0);
        llSetTimerEvent(0.1);
    }
    if (RemainingPrims > 1)
    {
        TemporaryLines += --link;
        ret += GetDrawLinePrimitiveParamsForLink(link, lastFrom, lastFrom+tempPartLength, true);
        lastFrom+=tempPartLength;
        llSetTimerEvent(0);
        llSetTimerEvent(0.1);
    }
    if (RemainingPrims > 2)
    {
        TemporaryLines += --link;
        ret += GetDrawLinePrimitiveParamsForLink(link, lastFrom, lastFrom+tempPartLength, true);
        lastFrom+=tempPartLength;
        llSetTimerEvent(0);
        llSetTimerEvent(0.1);
    }
    /*
    if (RemainingPrims > 0)
    {
        ret += [
            PRIM_LINK_TARGET, 1+RemainingPrims,
            PRIM_POS_LOCAL, to+(to-from)/2,
            PRIM_ROT_LOCAL, rot
        ];
    }
    if (RemainingPrims - 1 > 0)
    {
        ret += [
            PRIM_LINK_TARGET, 1+RemainingPrims - 1,
            PRIM_POS_LOCAL, to+(to-from)/2,
            PRIM_ROT_LOCAL, rot
        ];
    }
    if (RemainingPrims - 2 > 0)
    {
        ret += [
            PRIM_LINK_TARGET, 1+RemainingPrims - 2,
            PRIM_POS_LOCAL, to+(to-from)/2,
            PRIM_ROT_LOCAL, rot
        ];
    }*/
    return ret;
}

list GetDrawLinePrimitiveParamsForLink(int link, vector from, vector to, bool isTemporary)
{
    vector color = CurrentPenColor;
    if (color == BLACKBOARD_PEN_COLOR_RAINBOW)
    {
        color = GetColorFromScale(CurrentPenRainbowPercentage, DefaultScaleColorArray);
    }
    
    vector diff = from-to;
    float distance = llVecMag(diff);
    float rad = llAtan2(diff.x, diff.y);

    list type = [];
    if (from == to)
    {
        int TILES = 4;
        float x = ((int)llFrand(4)) * 1.0/TILES;
        float y = ((int)llFrand(4)) * 1.0/TILES;
        // [ PRIM_TYPE_CYLINDER, int hole_shape, vector cut, float hollow, vector twist, vector top_size, vector top_shear ] 
        type = [
            PRIM_TEXTURE, 0, CHALK_DOTS_TEXTURE, <1,1,0>/TILES, <x - 1.0/TILES/2, y- 1.0/TILES/2, 0>, llFrand(TWO_PI),
            PRIM_SIZE, <CurrentPenRadius, 0, CurrentPenRadius>
        ];
    }
    else
    {
        int TextureCharsY = 10;
        float yScaleThatEqualsOne = TextureCharsY/10.0;
        float textureDistance = distance * (yScaleThatEqualsOne/CurrentPenRadius);
        float repeatsPerMeter = 1;
        float horizontalScale = textureDistance*repeatsPerMeter*yScaleThatEqualsOne/20.0;

        if (!isTemporary)
        {
            HorizontalTextureOffset -= horizontalScale;
        }
        // 1 -> -1
        while (HorizontalTextureOffset<-1)
        {
            HorizontalTextureOffset += 2;
        }
        int textureY = (int)HorizontalTextureOffset;
        vector characterTextureScale = <
            horizontalScale,
            1.0/TextureCharsY,
            0>;
        float ySize = (1024.0-1024%TextureCharsY)/1024.0;
        vector textureOffset = <
            HorizontalTextureOffset,
            (1-textureY*characterTextureScale.y - characterTextureScale.y/2 - .5)*ySize + (1-ySize)/2,
            0>;

        // [ PRIM_TYPE_BOX, int hole_shape, vector cut, float hollow, vector twist, vector top_size, vector top_shear ] 
        // [ PRIM_TEXTURE, int face ]     17     [ string texture, vector repeats, vector offsets, float rotation_in_radians ] 
        type = [
            PRIM_TEXTURE, 0, CHALK_TEXTURE, characterTextureScale, textureOffset, PI_BY_TWO,
            PRIM_SIZE, <CurrentPenRadius, 0, distance>
        ];
    }
    
    vector targetPos = ((from+to)/2);
    rotation rot = llEuler2Rot(<PI_BY_TWO,0,0>)*llEuler2Rot(<0,0,-rad>);
    list ret = [
        PRIM_LINK_TARGET, link,
        PRIM_POS_LOCAL, targetPos,
        PRIM_ROT_LOCAL, rot,
        PRIM_COLOR, ALL_SIDES, color, 1
    ] + type;
    if (CurrentPenIsFullBright)
    {
        ret += [PRIM_FULLBRIGHT, ALL_SIDES, CurrentPenIsFullBright];
    }
    if (CurrentPenGlowStrength > 0)
    {
        ret += [PRIM_GLOW, ALL_SIDES, CurrentPenGlowStrength];
    }
    return ret;
}

#define BLACKBOARD_COMMAND_TYPE_TRIGGER_SOUND 123
#define BLACKBOARD_COMMAND_TYPE_LOOP_SOUND 124
#define BLACKBOARD_COMMAND_TYPE_STOP_SOUND 125

#define BLACKBOARD_COMMAND_CHANNEL 123444
#define BLACKBOARD_NOTECARD_REQUEST_CHANNEL 3425634156
#define BLACKBOARD_NOTECARD_RESPONSE_CHANNEL 3425634157
#define BLACKBOARD_INTERMEDIATE_MEMORY_CHANNEL 3425634158

#define BLACKBOARD_TEXT_BOARD_DEBUG_CHANNEL 1313133

#define BLACKBOARD_EVENT_DRAW_LINE 1
#define BLACKBOARD_EVENT_DRAW_LINE_STRIDE 3
#define AppendDrawLineEventPrimitiveParams(params, rawData, dataIndexOffset)\
{\
    vector from = (vector)llList2String(rawData, dataIndexOffset + 1);\
    vector to = (vector)llList2String(rawData, dataIndexOffset + 2);\
    params += GetDrawLinePrimitiveParams(from, to);\
}
#define BLACKBOARD_EVENT_DRAW_DOT 2
#define BLACKBOARD_EVENT_DRAW_DOT_STRIDE 2
#define AppendDrawDotEventPrimitiveParams(params, rawData, dataIndexOffset)\
{\
    vector pos = (vector)llList2String(rawData, dataIndexOffset + 1);\
    params += GetDrawLinePrimitiveParams(pos, pos);\
}
#define BLACKBOARD_EVENT_WIPE 3
#define BLACKBOARD_EVENT_WIPE_STRIDE 4
#define BLACKBOARD_EVENT_INIT 4
#define BLACKBOARD_EVENT_INIT_STRIDE 5
#define GetInitEventData(targetBuffer, LastOwnPos, LastOwnRot, zero) [BLACKBOARD_EVENT_INIT, targetBuffer, LastOwnPos, LastOwnRot, zero]
#define BLACKBOARD_EVENT_INIT_RESPONSE 5
#define BLACKBOARD_EVENT_INIT_RESPONSE_STRIDE 5
#define SendBufferInitResponse(isInitRequired) llSay(BLACKBOARD_COMMAND_CHANNEL, llList2CSV([BLACKBOARD_EVENT_INIT_RESPONSE, RezzerKey, BufferNumber, RemainingPrims, isInitRequired]))
#define BLACKBOARD_EVENT_SCOREBOARD_RESET 6
#define BLACKBOARD_EVENT_SCOREBOARD_SCORE 7
#define BLACKBOARD_EVENT_SCOREBOARD_ANNOUNCE 8
#define BLACKBOARD_EVENT_UNDO 9
#define BLACKBOARD_EVENT_UNDO_STRIDE 2
#define BLACKBOARD_EVENT_RECOVER_DATA 10
#define BLACKBOARD_EVENT_DIE 11
// [Color, GlowStrength, DrawRadius, IsFullbright, RainbowPercentage]
#define BLACKBOARD_EVENT_SET_PEN 12
#define BLACKBOARD_EVENT_SET_PEN_STRIDE 6
#define HandleSetPenEvent(data, i)\
{\
    CurrentPenColor = (vector)llList2String(data, i + 1);\
    CurrentPenGlowStrength = (float)llList2String(data, i + 2);\
    CurrentPenRadius = (float)llList2String(data, i + 3);\
    CurrentPenIsFullBright = (bool)llList2String(data, i + 4);\
    CurrentPenRainbowPercentage = (float)llList2String(data, i + 5);\
    if (CurrentPenRadius == 0)\
    {\
        llOwnerSay(llList2CSV(data));\
    }\
}

#define BLACKBOARD_EVENT_SET_PLAYER 13

// [Color, GlowStrength, DrawRadius, IsFullbright, RainbowPercentage]
#define BLACKBOARD_LINK_EVENT_SET_PEN 14

#define BLACKBOARD_PEN_COLOR_DEFAULT <1, 1, 1>
#define BLACKBOARD_PEN_GLOWSTRENGTH_DEFAULT 0
#define BLACKBOARD_PEN_IS_FULL_BRIGHT_DEFAULT false
#define BLACKBOARD_PEN_RADIUS_DEFAULT .02

vector CurrentPenColor = BLACKBOARD_PEN_COLOR_DEFAULT;
float CurrentPenGlowStrength = BLACKBOARD_PEN_GLOWSTRENGTH_DEFAULT;
float CurrentPenRadius = BLACKBOARD_PEN_RADIUS_DEFAULT;
bool CurrentPenIsFullBright = BLACKBOARD_PEN_IS_FULL_BRIGHT_DEFAULT;
float CurrentPenRainbowPercentage = 0;

#define BLACKBOARD_LINES_PER_BUFFER 255
#define BLACKBOARD_GAME_TIME 150

list StopDrawSounds = [
    "e566a68b-014f-d5c0-5a9d-72a1ab5dd3e0", .5
];
list StartDrawSounds = [
    "dd0ec20c-a43e-8049-45ad-b189b2e10965",
    "f00cb748-859e-f277-cc06-8ce6da64ae9e",
    "eb8d9ecb-ef47-29a4-434a-7c258990b84a",
    "2bc90aed-97f8-8427-5389-347b0de0641b",
    "07c86d8e-8359-8d52-e69c-027a6853ff2c",
    "01bd647c-c438-0107-b986-3b7e70af8f7d"
];
list DrawLoopSounds = [
    "f764233b-f3dd-393e-c65c-2ba33395c51a"
];