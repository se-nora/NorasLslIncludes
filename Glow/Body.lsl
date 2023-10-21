// possible definitions:
// - IsPatEnabled
// - IS_COLOR_HOST
// - Initiator

#include "Nora.lsl"
#ifdef IsPatEnabled
#include "Pats\PatDefinition.lsl"
#endif
#ifndef GetNextTouchGlowColor
#define GetNextTouchGlowColor() GetRandomColor()
#endif
#ifdef IS_COLOR_HOST
list ObjectGlowDefinition = [];
#endif

#ifndef OnSetParams
#define OnSetParams();
#endif

default
{
    state_entry()
    {
        GlowInit();

        llSetText("", <1,1,1>, 1);
        llListen(GLOW_CHANNEL, "", NULL_KEY, "");

        #ifndef IS_COLOR_HOST
        llRegionSay(GLOW_CHANNEL, GetGlowStatusMessage(llGetOwner()));
        #endif
        #ifdef IS_COLOR_HOST
        string linkSetData = llLinksetDataRead("GlowColors");
        if (linkSetData != "")
        {
            GlowColors = llCSV2List(llLinksetDataRead("GlowColors"));
        }
        else
        {
            SetNewColor(<0,0,0>);
            SetNewColor(<1,1,1>);
        }
        llRegionSay(GLOW_CHANNEL, GetGlowStatusResponseMessage(llGetOwner()));
        #endif

        int i = 0;
        
        #ifndef Initiator
        // figure out how much memory we should waste storing old colors
        while (i < llGetListLength(ObjectGlowDefinition))
        {
            if (llList2Integer(ObjectGlowDefinition, i++) == GLOW_PRIM_DEF_COLOR_OFFSET)
            {
                int requiredStoredColors = llList2Integer(ObjectGlowDefinition, i) + 1;
                if (MaxStoredColors < requiredStoredColors)
                {
                    MaxStoredColors = requiredStoredColors;
                }
                i++;
            }
        }
        #else
        MaxStoredColors = 8;
        #endif
    }

    on_rez(int n)
    {
        llResetScript();
    }

    attach(key k)
    {
        llResetScript();
    }

    #ifdef Initiator
    touch_start(integer n)
    {
        TouchTimeAdd = 0;
        while (n-- > 0)
        {
            vector newColor = GetNextTouchGlowColor();
            SetNewColor(newColor);
            
            llRegionSay(GLOW_CHANNEL, CreateChangeColorMessage(llGetOwner(), newColor));
            Glow(1, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, false);
            AnnounceGlow(1, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, false);
            float energyDrain = 10;
            if (llDetectedKey(n) != llGetOwner())
            {
                energyDrain = -10;
            }
            llRegionSay(GLOW_CHANNEL, CreateConsumeEnergyMessage(llGetOwner(), energyDrain));

            #ifdef IsPatEnabled
            SendPat(llDetectedKey(n), "patting my head ^.^");
            #endif
        }
        llResetTime();
    }

    touch(integer n)
    {
        TouchTimeAdd += llGetTime();
        while (n-- > 0)
        {
            //vector touchUv = llDetectedTouchUV(0);
            //TouchTimeAdd += llVecDist(LastTouchUv, touchUv);
            //llSetText((string)TouchTimeAdd+"\n\n\n a",<1,1,1>,1);
            //LastTouchUv = touchUv;
            if (TouchTimeAdd > 1)
            {
                //llOwnerSay((string)Color + (string)llGetTime());
                TouchTimeAdd = 0;
                llResetTime();
                Glow(1, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, false);
                AnnounceGlow(1, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED_DEFAULT, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION_DEFAULT, false);
                float energyDrain = 10;
                if (llDetectedKey(n) != llGetOwner())
                {
                    energyDrain = -10;
                }
                llRegionSay(GLOW_CHANNEL, CreateConsumeEnergyMessage(llGetOwner(), energyDrain));
            }
        }
    }
    #endif
    
    listen(int channel, string sender, key k, string message)
    {
        if (!IsEnabled) return;
        if (channel != GLOW_CHANNEL) return;

        key ownerKey = llGetOwnerKey(k);

        if (IsKeyOnBlackList(ownerKey)
            || !IsKeyOnWhiteList(ownerKey))
        {
            return;
        }

        list tokenizedMessage = GetTokenizedGlowProtocolMessage(message);

        int commandType = (int)llList2String(tokenizedMessage, 0);

        if (commandType == GLOW_PROTOCOL_COMMAND_TYPE_GLOW)
        {
            list params = GetAllParamsFromGlowMessage(tokenizedMessage);
            key target = llList2Key(params, GLOW_PROTOCOL_GLOW_COMMAND_KEY_TARGET);
            if (target != llGetOwner() && target != NULL_KEY)
            {
                return;
            }
    
            float glowStrength = llList2Float(params, GLOW_PROTOCOL_GLOW_COMMAND_GLOW_STRENGTH);
            float fadeSpeed = llList2Float(params, GLOW_PROTOCOL_GLOW_COMMAND_FADE_SPEED);
            float timerDuration = llList2Float(params, GLOW_PROTOCOL_GLOW_COMMAND_TIMER_DURATION);
            bool shouldForce = llList2Bool(params, GLOW_PROTOCOL_GLOW_COMMAND_IS_FORCED);
    
            Glow(glowStrength, fadeSpeed, timerDuration, shouldForce);
        }
        else if (commandType == GLOW_PROTOCOL_COMMAND_TYPE_CHANGE_COLOR)
        {
            list params = GetAllParamsFromChangeColorMessage(tokenizedMessage);
            key target = llList2Key(params, GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_KEY_TARGET);
            if (target != llGetOwner() && target != NULL_KEY)
            {
                return;
            }
            vector newColor = llList2Vector(params, GLOW_PROTOCOL_CHANGE_COLOR_COMMAND_COLOR);
            SetNewColor(newColor);
            SetParams(ObjectGlowDefinition);
        }
        else if (commandType == GLOW_PROTOCOL_GET_STATUS_RESPONSE_COMMAND)
        {
            list params = GetParamsFromGetStatusResponseMessage(tokenizedMessage);
            key target = llList2Key(params, 0);
            if (target != llGetOwner() && target != NULL_KEY)
            {
                return;
            }
            if (llGetListLength(params) > 1)
            {
                GlowColors = llList2List(params, 1, -1);
            }
            else
            {
                GlowColors = [];
            }
            SetParams(ObjectGlowDefinition);
        }
        #ifdef IS_COLOR_HOST
        else if (commandType == GLOW_PROTOCOL_COMMAND_TYPE_GET_STATUS)
        {
            list params = GetAllParamsFromGetStatusMessage(tokenizedMessage);
            key target = llList2Key(params, GLOW_PROTOCOL_GET_STATUS_COMMAND_KEY_TARGET);
            if (target != llGetOwner() && target != NULL_KEY)
            {
                return;
            }
            llRegionSayTo(k, GLOW_CHANNEL, GetGlowStatusResponseMessage(ownerKey));
        }
        #endif
        else
        {
            // unhandled
        }
    }
    
    timer()
    {
        if (ShouldTriggerSound)
        {
            #ifdef Initiator
            float soundVolume = GlowStrength * MaxSoundVolume * (.3+llFrand(.7));
            if (soundVolume > 0)
            {
                llTriggerSound(RandomStringListItem(InitiatorPoofSounds), soundVolume);
                llLoopSound(RandomStringListItem(InitiatorLoopSounds), soundVolume);
            }
            #else
            llTriggerSound(RandomStringListItem(ReceiverSoundEffects), .1);
            #endif
            ShouldTriggerSound = false;
        }

        GlowStrength -= FadeSpeed;

        #ifdef VERBOSE
        GlowStrength = 0;
        #endif
        
        if (GlowStrength <= 0)
        {
            GlowStrength = 0;
            llSetTimerEvent(0);
            IsTimerEnabled = false;
            #ifdef Initiator
            llStopSound();
            #endif
            
        }
        #ifdef Initiator
        else
        {
            llAdjustSoundVolume(GlowStrength*MaxSoundVolume*(.3+llFrand(.7)));
        }
        #endif

        SetParams(ObjectGlowDefinition);
    }
}
