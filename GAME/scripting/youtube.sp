#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define DELIMITER   "%20"

#define VERSION     "1.0.0"

char HexTable[] = "0123456789ABCDEF";
ConVar g_cvarBlankUrl, g_cvarBaseUrl;

char QueryString[] = "/?q=";

public Plugin myinfo = {
    name        = "Youtube Player with Data API",
    author      = "Jobggun",
    description = "You can let them play Youtube while playing game.",
    version     = VERSION,
    url         = "https://example.com"
};

public void OnPluginStart()
{
    CreateConVar("ytplayer_version", VERSION, "YouTube Player with Data API Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_SPONLY|FCVAR_DONTRECORD);
	g_cvarBaseUrl = CreateConVar("ytplayer_baseurl", "https://[WEBSERVER ADDRESS OR IP]/[Some directory if needed]/", "Youtube WebServer Base URL");
    g_cvarBlankUrl = CreateConVar("ytplayer_blankurl", "https://youtube.com", "Youtube Player Blank Url for Managing misc. things.");
    
    RegConsoleCmd("sm_yt", Cmd_PlayMusic);
    RegConsoleCmd("sm_ytplay", Cmd_PlayMusic);
    
    RegAdminCmd("sm_ytto", Cmd_PlayMusicTo, ADMFLAG_SLAY);
    RegAdminCmd("sm_ytplayto", Cmd_PlayMusicTo, ADMFLAG_SLAY);
    
    RegConsoleCmd("sm_ytshow", Cmd_PlayMusicShow);
    RegConsoleCmd("sm_ytplayshow", Cmd_PlayMusicShow);
    
    RegConsoleCmd("sm_ytstop", Cmd_StopMusic);
    RegConsoleCmd("sm_ytplaystop", Cmd_StopMusic);
}

public Action Cmd_PlayMusic(int client, int args)
{
    if(args == 0)
    {
        ReplyToCommand(client, "Usage: !yt <search keyword> or !ytplay <search keyword>");
        return Plugin_Handled;
    }
	char arg[256], encodedArg[768], url[1024];
	
	g_cvarBaseUrl.GetString(url, sizeof(url));
	StrCat(url, sizeof(url), QueryString);
    
    GetCmdArgString(arg, sizeof(arg));
    urlEncode(arg, encodedArg, sizeof(encodedArg));
    StrCat(url, sizeof(url), encodedArg);
    
    ShowMOTDPanelEx(client, "[Youtube Player]", url, MOTDPANEL_TYPE_URL, true);
    
    ReplyToCommand(client, "Youtube will start in a few seconds. Use !ytstop or !ytplaystop to stop, !ytshow or !ytplayshow to display youtube, where you can modify the volume");
    
    return Plugin_Handled;
}

public Action Cmd_PlayMusicTo(int client, int args)
{    
	if(args <= 1)
    {
        ReplyToCommand(client, "Usage: !ytto <target> <search keyword> or !ytplayto <target> <search keyword>");
        return Plugin_Handled;
    }
    
	char arg[256], encodedArg[768], url[1024];
	
	g_cvarBaseUrl.GetString(url, sizeof(url));
	StrCat(url, sizeof(url), QueryString);
	
    GetCmdArg(1, arg, sizeof(arg));
    
    char target_name[MAX_TARGET_LENGTH];
    int target_list[MAXPLAYERS], target_count;
    bool tn_is_ml;
    
    if((target_count = ProcessTargetString(
        arg,
        client,
        target_list,
        MAXPLAYERS,
        COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_BOTS,
        target_name,
        sizeof(target_name),
        tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }
    
    for(int i = 2; i <= args; i++)
    {
        GetCmdArg(i, arg, sizeof(arg));
        urlEncode(arg, encodedArg, sizeof(encodedArg));
        StrCat(url, sizeof(url), encodedArg);
        StrCat(url, sizeof(url), DELIMITER);
    }
    
    for (int i = 0; i < target_count; i++)
    {
        PrintToChat(target_list[i], "Youtube will start in a few seconds. Use !ytstop or !ytplaystop to stop, !ytshow or !ytplayshow to display youtube, where you can modify the volume");
        ShowMOTDPanelEx(target_list[i], "[Youtube Player]", url, MOTDPANEL_TYPE_URL, true);
        
        LogAction(client, target_list[i], "\"%L\" made \"%L\" play youtube", client, target_list[i]);
    }
    
    if (tn_is_ml)
    {
        ShowActivity2(client, "[SM] ", "Started music for targets %t.", target_name);
    }
    else
    {
        ShowActivity2(client, "[SM] ", "Started music for targets %s.", target_name);
    }
    
    return Plugin_Handled;
}

public Action Cmd_PlayMusicShow(int client, int args)
{
    char url[256];
    g_cvarBlankUrl.GetString(url, sizeof(url));
    ShowMOTDPanelEx(client, "[Youtube Player]", url, MOTDPANEL_TYPE_URL, true);
    return Plugin_Handled;
}

public Action Cmd_StopMusic(int client, int args)
{
    ShowMOTDPanelEx(client, "[Youtube Player]", "about:blank", MOTDPANEL_TYPE_URL, false);
    return Plugin_Handled;
}

void urlEncode(const char[] input, char[] output, int outputLen)
{
    int inputIndex = 0, outputIndex = 0;
    
    char temp;
    
    while(outputIndex < outputLen)
    {
        temp = input[inputIndex++];
        
        if((temp >= '0' && temp <= '9') ||
            (temp >= 'A' && temp <= 'Z') ||
            (temp >= 'a' && temp <= 'z') ||
            (temp == '-') || (temp == '.') ||
            (temp == '_') || (temp == '~'))
        {
            output[outputIndex++] = temp;
        }
        else if (temp == '\0')
        {
            output[outputIndex++] = temp;
            break;
        }
        else
        {
            if(outputIndex + 4 > outputLen)
            {
                output[outputIndex++] = '\0';
                break;
            }
            
            output[outputIndex++] = '%';
            output[outputIndex++] = HexTable[temp >> 4];
            output[outputIndex++] = HexTable[temp & 15];
        }
    }
}

void ShowMOTDPanelEx(int client, const char[] title, const char[] msg, int type = MOTDPANEL_TYPE_INDEX, bool show = true)
{
    char sType[3];
    IntToString(type, sType, sizeof(sType));

    KeyValues kv = new KeyValues("data");
    kv.SetString("title", title);
    kv.SetString("type", sType);
    kv.SetString("msg", msg);
    ShowVGUIPanel(client, "info", kv, show);
    delete kv;
}
