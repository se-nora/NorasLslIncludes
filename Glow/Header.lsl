#include "Nora.lsl"
#include "GlowProtocol.lsl"

float GlowStrength = 0;
float FadeSpeed = GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT;
list GlowColors = [];
int MaxStoredColors = 8;
bool IsTimerEnabled = 0;

// if an error happens, the script gets disabled
bool IsEnabled = true;

// set on Glow() when timer is not yet running
bool ShouldTriggerSound = false;

list ReceiverSoundEffects = [
    "71f4a136-3e85-6ba3-ec1e-d0d77df2e42f",
    "f782ed2c-30e1-847d-cbb4-d7c024857771",
    "2fd6fbbe-b712-6134-a7db-9f9b4d427e3d",
    "55a2a894-6fd9-221f-0b2a-e1d672ddf081"
];

list InitiatorPoofSounds = [
    "0829fe56-c9c2-a53a-1f71-a65178fe7132",
    "bbcc9f09-e492-99f7-08c3-d5a896c28c75",
    "d7a76c15-ab44-36d4-b5e9-fa275ff2589e",
    "1bcadc26-c5cf-da54-af72-cdc4dc4ae9b8",
    "a8ac2540-f271-8a6c-83ef-23725b5fb2e6",
    "585c4a71-9c16-bbac-51fd-cd9a25cebb7d",
    "bf7ccf36-1a39-939b-e024-8ba0f66b5e15",
    "03ddc4a2-6883-1923-1c29-e40c092d0a86",
    "5d050bda-625f-44ed-166d-c786162db4e2"
];

list InitiatorLoopSounds =[
    "8e9642e8-e31d-51c4-8bad-f083cb94c8ee",
    "39b22244-27ab-715c-3d10-72a5872fe3a1"
];

list GlowCollisionSounds = [
    "bb466d6e-625d-1018-6bb7-6e16ebbf8d51",
    "ef80fefe-c33e-47ae-84e6-5529aa353476",
    "f77c0b9d-7b11-03aa-bb2e-efb56548a4d5",
    "0b264f8b-6a89-fce6-782b-9745b2ca7906",
    "5a4797b5-63c0-d0f4-0094-20baa428bb92",
    "d544b3af-6f23-3d0b-b17e-bf52252a1c88",
    "7a07949f-b487-287c-de0b-3f1b6227acf9"
];

#ifdef Initiator
#define MaxSoundVolume .7

key LastTouchKey;
vector LastTouchUv;

float TouchTimeAdd = 0;
key LastToucher;

#else
#define MaxSoundVolume .2
#endif

#define GlowInit()

SetNewColor(vector newColor)
{
    if (MaxStoredColors == 1)
    {
        GlowColors = [newColor];
    }
    else if (llGetListLength(GlowColors) < MaxStoredColors)
    {
        GlowColors = [newColor] + GlowColors;
    }
    else
    {
        GlowColors = [newColor] + llList2List(GlowColors, 0, -2);
    }

    #ifdef IS_COLOR_HOST
    llLinksetDataWrite("GlowColors", llList2CSV(GlowColors));
    #endif
}

AnnounceGlow(float strength, float fadeSpeed, float timerDuration, bool shouldForce)
{
    llRegionSay(
        GLOW_CHANNEL,
        CreateGlowMessage(
            llGetOwner(),
            strength,
            fadeSpeed,
            timerDuration,
            shouldForce));
}
Glow(float strength, float fadeSpeed, float timerDuration, bool shouldForce)
{
    if (strength > 1)
    {
        strength = 1;
    }
    
    /*float time = llGetAndResetTime();
    if (time < 1 && !isForced)
    {
        newColor = llVecNorm((llList2Vector(GlowColors, 0) + newColor)/2);
    }*/

    /*#ifdef Initiator
    if (shouldAnnounce)
    {
        if (FadeSpeed != GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT)
        {
            llRegionSay(
                GLOW_CHANNEL,
                CreateGlowMessage(
                    llGetOwner(), // key target
                    strength, // float strength
                    fadeSpeed, // float fadeSpeed
                    GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, // float timerDuration
                    GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED_DEFAULT)); // bool isForced
        }
        else
        {
            llRegionSay(GLOW_CHANNEL, CreateGlowMessageDefault(llGetOwner(), strength));
        }
        //llRegionSay(GLOW_CHANNEL, CreateGlowMessageDefault(NULL_KEY, 1));
    }
    #endif*/
    
    GlowStrength = strength;
    FadeSpeed = fadeSpeed;

    if (!IsTimerEnabled)
    {
        ShouldTriggerSound = true;
        IsTimerEnabled = true;
        llSetTimerEvent(timerDuration);
    }
}

#define GLOW_PRIM_DEF_LINK 1
#define GLOW_PRIM_DEF_LINK_DEFAULT LINK_THIS
#define GLOW_PRIM_DEF_FACE 2
#define GLOW_PRIM_DEF_FACE_DEFAULT ALL_SIDES
#define GLOW_PRIM_DEF_MIN_GLOW_STRENGTH 3
#define GLOW_PRIM_DEF_MIN_GLOW_STRENGTH_DEFAULT 0
#define GLOW_PRIM_DEF_MAX_GLOW_STRENGTH 4
#define GLOW_PRIM_DEF_MAX_GLOW_STRENGTH_DEFAULT .5
#define GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR 5
#define GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR_DEFAULT 1
#define GLOW_PRIM_DEF_FADE_TO_COLOR 6
#define GLOW_PRIM_DEF_BASE_COLOR 7
#define GLOW_PRIM_DEF_BASE_COLOR_DEFAULT <0,0,0>
#define GLOW_PRIM_DEF_COLOR_OFFSET 8
#define GLOW_PRIM_DEF_COLOR_OFFSET_DEFAULT 0
#define GLOW_PRIM_DEF_ALPHA 9
#define GLOW_PRIM_DEF_ALPHA_DEFAULT 1

// A link definition looks like this:
// Trivia: 
//   default = LINK_THIS and ALL_SIDES if ObjectGlowDefinition is empty
// 
// int GLOW_PRIM_DEF_LINK
//   int Link - the link you want to let glow, default = LINK_THIS
//     int GLOW_PRIM_DEF_FACE
//     int Face - the Face you want to let glow
//       int GLOW_PRIM_DEF_MIN_GLOW_STRENGTH
//         float MinGlowStrength - minimum remaining glow strength after fade out, [0-1], default = 0
//       int GLOW_PRIM_DEF_MAX_GLOW_STRENGTH
//         float MaxGlowStrength - minimum remaining glow strength after fade out, [0-1], default = .5
//       int GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR
//         float ColorBrightness - a factor the color is multiplied with, [0-1], default = 1
//       int GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR
//         float ColorBrightness - a factor the color is multiplied with, [0-1], default = 1
//       int GLOW_PRIM_DEF_FADE_TO_COLOR
//         vector Color, if this is defined, the glow will only glow in the color while glowing, and fading towards this color when losing "strength", defaults = glow color
//       int GLOW_PRIM_DEF_BASE_COLOR
//         vector Color, if this is defined, the color will be additionally added, so if you take <1,1,1>, it will add this color to the glow color, the resulting normalized color is then used
//       int GLOW_PRIM_DEF_COLOR_OFFSET, specifier to determine if an "older" color should be used
//         int offset, the color will be additionally added, so if you take <1,1,1>, it will add this color to the glow color, the resulting normalized color is then used, [0-7], default = 0
//       int GLOW_PRIM_DEF_ALPHA
//         float alpha, the alpha of the color [0-1], default = 1

#define ParseError() llSay(DEBUG_CHANNEL, "Encountered invalid object glow definition, cancelling update, disabling."); IsEnabled = false
vector ColorSubNorm(vector c)
{
    if (c.x > 1) c.x = 1;
    if (c.y > 1) c.y = 1;
    if (c.z > 1) c.z = 1;
    if (c.x < 0) c.x = 0;
    if (c.y < 0) c.y = 0;
    if (c.z < 0) c.z = 0;
    return c;
}
#define GetGlowColor(offset) llList2Vector(GlowColors, offset)
#define GlowColor GetGlowColor(0)

#define GetFaceParams(alpha) [\
    PRIM_COLOR, glowFace, ColorSubNorm(glowColorAddColor + glowColorFadeToColor*(1-GlowStrength)*glowColorBrightnessFactor + glowColor*GlowStrength*glowColorBrightnessFactor), alpha,\
    PRIM_GLOW, glowFace, glowMinStrength + (glowMaxStrength-glowMinStrength) * GlowStrength\
\]
#define GetLinkParams() [PRIM_LINK_TARGET, glowLink]

#define AddFaceParams(glowColor, alpha) Verbose("+ " + llList2CSV(GetFaceParams(alpha)));\
    vector glowColorFadeToColor = glowColor;\
    if (glowColorFadeToColorString != "")\
    {\
        glowColorFadeToColor = (vector)glowColorFadeToColorString;\
    }\
    params += GetFaceParams(alpha)
#define AddLinkParams() Verbose("+ " + llList2CSV(GetLinkParams()));\
    params += GetLinkParams()

SetParams(list objectGlowDefinition)
{
    OnSetParams();
    int i = 0;
    int objectGlowDefinitionCount = llGetListLength(objectGlowDefinition);
    if (objectGlowDefinitionCount == 0)
    {
        return;
    }

    int glowLink = GLOW_PRIM_DEF_LINK_DEFAULT;
    int firstLink = glowLink;
    int glowFace = GLOW_PRIM_DEF_FACE_DEFAULT;
    int glowColorOffset = GLOW_PRIM_DEF_COLOR_OFFSET_DEFAULT;
    string glowColorFadeToColorString = "";
    float glowMinStrength = GLOW_PRIM_DEF_MIN_GLOW_STRENGTH_DEFAULT;
    float glowMaxStrength = GLOW_PRIM_DEF_MAX_GLOW_STRENGTH_DEFAULT;
    float glowColorBrightnessFactor = GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR_DEFAULT;
    vector glowColorAddColor = GLOW_PRIM_DEF_BASE_COLOR_DEFAULT;
    float alpha = GLOW_PRIM_DEF_ALPHA_DEFAULT;

    int previousWhat = GLOW_PRIM_DEF_LINK;
    list params = [];
    while (i <= objectGlowDefinitionCount)
    {
        if (i == objectGlowDefinitionCount)
        {
            vector glowColor = GetGlowColor(glowColorOffset);
            AddFaceParams(glowColor, alpha);

            jump break;
        }

        int what = llList2Integer(objectGlowDefinition, i++);
        if (i == objectGlowDefinitionCount)
        {
            ParseError();
            return;
        }

        if (what == GLOW_PRIM_DEF_LINK)
        {
            // if we had no data before, or the previous data was not a link, then we need to paint the previous face
            if (i != 1
                || previousWhat != GLOW_PRIM_DEF_LINK)
            {
                vector glowColor = GetGlowColor(glowColorOffset);
                // the first face can be set directly
                AddFaceParams(glowColor, alpha);
            }

            glowLink = llList2Integer(objectGlowDefinition, i++);
            if (firstLink == LINK_THIS)
            {
                firstLink = glowLink;
            }
            else if (i != 2)
            {
                AddLinkParams();
            }

            // set defaults again for each new link
            glowFace = GLOW_PRIM_DEF_FACE_DEFAULT;
            glowColorOffset = GLOW_PRIM_DEF_COLOR_OFFSET_DEFAULT;
            glowMinStrength = GLOW_PRIM_DEF_MIN_GLOW_STRENGTH_DEFAULT;
            glowMaxStrength = GLOW_PRIM_DEF_MAX_GLOW_STRENGTH_DEFAULT;
            glowColorBrightnessFactor = GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR_DEFAULT;
            glowColorFadeToColorString = "";
            glowColorAddColor = GLOW_PRIM_DEF_BASE_COLOR_DEFAULT;
            alpha = GLOW_PRIM_DEF_ALPHA_DEFAULT;
            Verbose("Link: " + (string)glowLink);
        }
        else if (what == GLOW_PRIM_DEF_FACE)
        {
            // if previous was not link, then we need to finish the previous face
            if (previousWhat != GLOW_PRIM_DEF_LINK)
            {
                vector glowColor = GetGlowColor(glowColorOffset);
                AddFaceParams(glowColor, alpha);
            }

            // set defaults again for each new face
            glowColorOffset = GLOW_PRIM_DEF_COLOR_OFFSET_DEFAULT;
            glowMinStrength = GLOW_PRIM_DEF_MIN_GLOW_STRENGTH_DEFAULT;
            glowMaxStrength = GLOW_PRIM_DEF_MAX_GLOW_STRENGTH_DEFAULT;
            glowColorBrightnessFactor = GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR_DEFAULT;
            glowColorFadeToColorString = "";
            glowColorAddColor = GLOW_PRIM_DEF_BASE_COLOR_DEFAULT;
            alpha = GLOW_PRIM_DEF_ALPHA_DEFAULT;

            glowFace = llList2Integer(objectGlowDefinition, i++);
            Verbose("  Face: " + (string)glowFace);
        }
        #define switchCase(c, name, type)\
        else if (what == c)\
        {\
            name = llList2##type(objectGlowDefinition, i++);\
            Verbose("    " + #name + ":"" + (string)name);\
        }
        switchCase(GLOW_PRIM_DEF_MIN_GLOW_STRENGTH, glowMinStrength, Float)
        switchCase(GLOW_PRIM_DEF_MAX_GLOW_STRENGTH, glowMaxStrength, Float)
        switchCase(GLOW_PRIM_DEF_COLOR_BRIGHTNESS_FACTOR, glowColorBrightnessFactor, Float)
        switchCase(GLOW_PRIM_DEF_FADE_TO_COLOR, glowColorFadeToColorString, String)
        switchCase(GLOW_PRIM_DEF_BASE_COLOR, glowColorAddColor, Vector)
        switchCase(GLOW_PRIM_DEF_COLOR_OFFSET, glowColorOffset, Integer)
        switchCase(GLOW_PRIM_DEF_ALPHA, alpha, Float)
        else
        {
            ParseError();
            return;
        }
        #undef switchCase
        
        previousWhat = what;
    }
    @break;

    Verbose((string)firstLink+ ", [" + llList2CSV(params)+"]");

    if (llGetListLength(params))
    {
        llSetLinkPrimitiveParamsFast(firstLink, params);
    }
}
