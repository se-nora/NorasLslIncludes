#ifndef NORA_LIST2CSV
    #define NORA_LIST2CSV
    #include "Compress.lsl"
    #define SubList2CSV(...) SubList2Csv(__VA_ARGS__)
    #define List2CSV(...) SubList2Csv(__VA_ARGS__, 0, -1)
    #define List2Csv(...) List2CSV(__VA_ARGS__)
    #define CSV2List(...) Csv2List(__VA_ARGS__)

    string SubList2Csv(list l, int from, int to)
    {
        int i = from;
        int c;
        int n = llGetListLength(l);
        if (to < 0)
        {
            to = n + to;
        }
        if (to > n)
        {
            to = n-1;
        }
        c = to + 1;

        string ret;
        while(i < c)
        {
            if (i == from)
            {
                ret = CompressParam(llList2String(l, i++), false);
            }
            else
            {
                ret += "," + CompressParam(llList2String(l, i++), false);
            }
        }
        return ret;
    }

    list Csv2List(string csv)
    {
        list dataRaw = llCSV2List(csv);
        int i = 0;
        int c = llGetListLength(dataRaw);
        list data;
        while (i<c)
        {
            data += ConvertToLslType(llList2String(dataRaw, i++));
        }
        return data;
    }
#endif
