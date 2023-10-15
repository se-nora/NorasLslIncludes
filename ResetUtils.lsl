key ResetOnLinkChange_LastLastLinkKey = NULL_KEY;

#define ResetOnLinkChangeNoAvatar(change) {\
    if (change & CHANGED_LINK)\
    {\
        key lastLinkKey = llGetLinkKey(llGetNumberOfPrims());\
        if (lastLinkKey != ResetOnLinkChange_LastLastLinkKey)\
        {\
            bool isLastLastLinkKeyAvatar = IsAvatar(ResetOnLinkChange_LastLastLinkKey);\
            bool isLastLinkKeyAvatar = IsAvatar(lastLinkKey);\
            if (!isLastLinkKeyAvatar && !isLastLastLinkKeyAvatar)\
            {\
                llResetScript();\
            }\
        }\
        ResetOnLinkChange_LastLastLinkKey = lastLinkKey;\
    }\
}

#define ResetOnLinkChange(change) {\
    if (change & CHANGED_LINK)\
    {\
        llResetScript();\
    }\
}
