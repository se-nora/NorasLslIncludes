//#define RUN_UNIT_TESTS

#define PAT_PROTOCOL_PAT_CHANNEL -21546
// key, string action, int optional<amount>, string optional<name>, string optional<firstPat>, string optional<lastPat>
#define PAT_PROTOCOL_PAT_EVENT 1
#define PAT_PROTOCOL_PRINT_PUBLIC_EVENT 2
#define PAT_PROTOCOL_PRINT_OWNER_EVENT 3
#define PAT_PROTOCOL_DUMP_DATA_EVENT 4
// target, channel
#define PAT_PROTOCOL_PRINT_TO_KEY_EVENT 5
// target, channel
#define PAT_PROTOCOL_PRINT_SPECIFIC_DATA_EVENT 6
#define SendPat(k, action) SendPatEvent(k, PAT_PROTOCOL_PAT_EVENT, action, 1)
#define SendPatEvent(sender, eventType, ...) llRegionSay(PAT_PROTOCOL_PAT_CHANNEL, llList2CSV([eventType, sender] + [__VA_ARGS__]))
#define SendPatEventToLink(sender, eventType, ...) llMessageLinked(LINK_THIS, PAT_PROTOCOL_PAT_CHANNEL, llList2CSV([eventType, sender] + [__VA_ARGS__]), sender)
#define GetPatEventMessage(eventType, k, action, amount) llList2CSV([eventType, k, action, amount])
#define PATTERS_STRIDE 5

// key, pats, name, firstPat, lastPat
#define PatterEntry list
// list of PatterEntry
#define PatterEntries list
#define PatterPrefix "PP"
#define PAT_KEY_INDEX_OFFSET 0
#define PAT_PATS_INDEX_OFFSET 1
#define PAT_NAME_INDEX_OFFSET 2
#define PAT_FIRST_PAT_INDEX_OFFSET 3
#define PAT_LAST_PAT_INDEX_OFFSET 4

#define GetLinkSetDataKey(patterKey) PatterPrefix + (string)patterKey
#define GetPatterKey(patterEntry) llList2Key(patterEntry, PAT_KEY_INDEX_OFFSET)
#define GetPatterPats(patterEntry) llList2Int(patterEntry, PAT_PATS_INDEX_OFFSET)
#define GetPatterLastPatTime(patterEntry) llList2String(patterEntry, PAT_LAST_PAT_INDEX_OFFSET)
#define GetPatterName(patterKey) GetFirstNameOrDefault(patterKey, llList2String(GetPatterEntry(patterKey), PAT_NAME_INDEX_OFFSET))

#define LinkSetData2Patter(patterKey, linksetData) ([ patterKey, (int)llList2String(linksetData, 0) ] + llList2List(linksetData, 1, -1))
#define Patter2LinkSetData(patterEntry) llList2CSV(llList2List(patterEntry, 1, -1))

#define RemovePatter(patterKey) llLinksetDataDelete(GetLinkSetDataKey(patterKey))
#define GetNewPatter(patterKey, pats) [patterKey, pats, GetFirstName(patterKey), llGetTimestamp(), llGetTimestamp()]

#define GetTotal() ((int)llLinksetDataRead(GetLinkSetDataKey("Total")))
#define IncreaseTotal(amount) llLinksetDataWrite(GetLinkSetDataKey("Total"), (string)(amount + GetTotal()))

PatterEntries GetAllPatters()
{
    list linkSetDataKeys = llLinksetDataListKeys(0, -1);
    PatterEntries patters = [];
    int c = 0;
    while(c < llGetListLength(linkSetDataKeys))
    {
        string linkSetDataKey = llList2String(linkSetDataKeys, c++);

        if (llSubStringIndex(linkSetDataKey, PatterPrefix) == 0)
        {
            key patterKey = (key)llGetSubString(linkSetDataKey, llStringLength(PatterPrefix), -1);
            if (patterKey != "Total")
            {
                // one linksetData is pats;name;firstPat;lastPat
                list linkSetData = llCSV2List(llLinksetDataRead(linkSetDataKey));
                patters += [patterKey, (int)llList2String(linkSetData, 0)] + llList2List(linkSetData, 1, -1);
            }
        }
    }

    return patters;
}

#define DeleteOldestScore()\
{\
    int patterIndex = 0;\
    key olderstPatterKey = NULL_KEY;\
    string olderstPatTime = "a";\
\
    list linkSetDataKeys = llLinksetDataListKeys(0, -1);\
    int c = 0;\
    while(c < llGetListLength(linkSetDataKeys))\
    {\
        string linkSetDataKey = llList2String(linkSetDataKeys, c++);\
\
        if (llSubStringIndex(linkSetDataKey, PatterPrefix) == 0)\
        {\
            key patterKey = (key)llGetSubString(linkSetDataKey, llStringLength(PatterPrefix), -1);\
            PatterEntry patter = GetPatterEntry(patterKey);\
\
            string lastPatTime = GetPatterLastPatTime(patter);\
\
            if (StringCompare(lastPatTime, olderstPatTime) < 0)\
            {\
                olderstPatTime = lastPatTime;\
                olderstPatterKey = patterKey;\
            }\
        }\
    }\
\
    if (olderstPatterKey != NULL_KEY)\
    {\
        RemovePatter(olderstPatterKey);\
    }\
}

AddOrUpdateEntry(PatterEntry patterEntry)
{
    PatterEntry oldEntry = GetPatterEntry(GetPatterKey(patterEntry));
    int patterPats = GetPatterPats(oldEntry);
    if (patterPats != 0)
    {
        IncreaseTotal(-patterPats);
    }
    patterPats = GetPatterPats(patterEntry);
    IncreaseTotal(patterPats);

    int memoryStatus = llLinksetDataWrite(GetLinkSetDataKey(GetPatterKey(patterEntry)), Patter2LinkSetData(patterEntry));

    while (memoryStatus == LINKSETDATA_EMEMORY)
    {
        DeleteOldestScore();
        memoryStatus = llLinksetDataWrite(GetLinkSetDataKey(GetPatterKey(patterEntry)), Patter2LinkSetData(patterEntry));
    }
}

PatterEntry GetPatterEntry(key patterKey)
{
    string linkSetData = llLinksetDataRead(GetLinkSetDataKey(patterKey));
    if (linkSetData == "")
    {
        return GetNewPatter(patterKey, 0);
    }

    return LinkSetData2Patter(patterKey, llCSV2List(linkSetData));
}

PatterEntries GetSortedScores()
{
    PatterEntries allPatters = GetAllPatters();
    allPatters = llListSortStrided(allPatters, PATTERS_STRIDE, PAT_PATS_INDEX_OFFSET, false);
    return allPatters;
}

string GetScores()
{
    PatterEntries sortedPatters = GetSortedScores();
    string message = "Pats! Total: " + (string)GetTotal();
    integer i = 0;

    while (i < llGetListLength(sortedPatters))
    {
        key patterKey = llList2Key(sortedPatters, i + PAT_KEY_INDEX_OFFSET);
        int pats = llList2Integer(sortedPatters, i + PAT_PATS_INDEX_OFFSET);
        string name = GetPatterName(patterKey);
        string line = "\n" + (string)pats + " - " + name;

        if (llStringLength(line) + llStringLength(message) > MAX_PUBLIC_MESSAGE_LENGTH)
        {
            i = llGetListLength(sortedPatters);
        }
        else
        {
            if (llStringLength(message) + llStringLength(line) > MAX_PUBLIC_MESSAGE_LENGTH)
            {
                return message;
            }
            message += line;
        }
        
        i += PATTERS_STRIDE;
    }

    return message;
}


string GetTotalPatMessage(key highlightPatterKey)
{
    PatterEntry patterEntry = GetPatterEntry(highlightPatterKey);
    int highlightPatterContribution = GetPatterPats(patterEntry);

    string message = "Total pats: " + (string)GetTotal();
    if (highlightPatterKey != NULL_KEY && highlightPatterContribution != 0)
    {
        message += ", of those you (" + GetPatterName(highlightPatterKey) + "), contributed: " + (string)highlightPatterContribution;
    }
    return message;
}

DumpPatters()
{
    int i = 0;
    PatterEntries patters = GetAllPatters();
    while (i < llGetListLength(patters))
    {
        llOwnerSay("(key)\"" + (string)llList2Key(patters, i) + "\""
            + ", " + (string)llList2Integer(patters, i+1)
            + ", \"" + llList2String(patters, i+2) + "\""
            + ", \"" + llList2String(patters, i+3) + "\""
            + ", \"" + llList2String(patters, i+4) + "\",");

        i += PATTERS_STRIDE;
    }
}
