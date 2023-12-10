
string GetLinkPrimitiveParamsAsSendableString(list params)
{
    string s;
    int i = 0;
    int c = llGetListLength(params);
    while (i < c)
    {
        int link = llList2Int(params, i);
        int param = llList2Int(params, i+1);
        if (i > 0)
        {
            s+=",";
        }
        s += (string)param +","+List2CSV(llGetLinkPrimitiveParams(link, [param]));
        i+=2;
    }
    return s;
}
