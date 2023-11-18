integer GetCharValue(string chr)
{
    if (chr == "")
    {
        return 0;
    }
    chr = llGetSubString(chr, 0, 0);
    string hex = llEscapeURL(chr);
    if (llGetSubString(hex, 0, 0) != "%")
    {
        // Regular character - we can't take advantage of llEscapeURL in this case,
        // so we use llStringToBase64/llBase64ToInteger instead.
        return llBase64ToInteger("AAAA" + llStringToBase64(chr));
    }
    integer b = (integer)("0x" + llGetSubString(hex, 1, 2));
    if (b < 194 || b > 244)
    {
        return b;
    }
    if (b < 224)
    {
        return ((b & 0x1F) << 6) | (integer)("0x" + llGetSubString(hex, 4, 5)) & 0x3F;
    }
    integer cp;
    if (b < 240)
    {
        cp = ((b & 0x0F) << 12)
         + (((integer)("0x" + llGetSubString(hex, 4, 5)) & 0x3F) << 6)
         + ((integer)("0x" + llGetSubString(hex, 7, 8)) & 0x3F);
        return cp;
    }
    cp = ((b & 0x07) << 18)
     + (((integer)("0x" + llGetSubString(hex, 4, 5)) & 0x3F) << 12)
     + (((integer)("0x" + llGetSubString(hex, 7, 8)) & 0x3F) << 6)
     + ((integer)("0x" + llGetSubString(hex, 10, 11)) & 0x3F);
    return cp;
}

string UrlCode(integer b)
{
    string hexd = "0123456789ABCDEF";
    return "%" + llGetSubString(hexd, b>>4, b>>4)
               + llGetSubString(hexd, b&15, b&15);
}
 
// Chr function itself, which implements Unicode to UTF-8 conversion and uses
// llUnescapeURL to do its job.
string GetChar(integer ord)
{
    if (ord <= 0)
    {
        return "";
    }
    if (ord < 0x80)
    {
        return llUnescapeURL(UrlCode(ord));
    }
    if (ord < 0x800)
    {
        return llUnescapeURL(
            UrlCode((ord >> 6) | 0xC0)
            + UrlCode(ord & 0x3F | 0x80));
    }
    if (ord < 0x10000)
    {
        return llUnescapeURL(
            UrlCode((ord >> 12) | 0xE0)
            + UrlCode((ord >> 6) & 0x3F | 0x80)
            + UrlCode(ord & 0x3F | 0x80));
    }
    return llUnescapeURL(
        UrlCode((ord >> 18) | 0xF0)
        + UrlCode((ord >> 12) & 0x3F | 0x80)
        + UrlCode((ord >> 6) & 0x3F | 0x80)
        + UrlCode(ord & 0x3F | 0x80));
}
