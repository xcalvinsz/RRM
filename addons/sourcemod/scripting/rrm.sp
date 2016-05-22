/*	
 *	============================================================================
 *	
 *	[TF2] Random Round Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	This is the core plugin that manages modifiers (sub-plugins)
 *
 *	============================================================================
 */
 //fix timer onmodifierunload when there are 0 modifiers
 //timer now actively removes subplugins that gets unloaded
 //forgot to remove debug messages
 //auto pick modifier if plugin is lateloaded instead of waiting on next round
 //clean/tidy the code from core/sub-plugins
 //added convars to each of the sub-plugins check cfg/rrm folder
 //replaced the modifier notification hud with regular colored chat message
 //Added 5 new modifiers (jump/secondarydmg/primarydmg/meleedmg/gravity)
#pragma semicolon 1

#define RRM_VERSION "1.0"
#define MAX_STRING_LENGTH 256
#define MAX_PLUGIN_LENGTH 128
//#define GREEN 	"{green}"
//#define DEFAULT "{default}"

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>
#include <morecolors>

#pragma newdecls required

ArrayList gArray = null;
Handle gOnRegOpen = null;
DataPack gCurrentModifier = null;

int gIsRegOpen = 0;
//bool gIsMinHUDEnabled[MAXPLAYERS + 1] =  { false, ... };

public Plugin myinfo = 
{
	name = "[TF2] Random Round Modifier",
	author = RRM_AUTHOR,
	description = "Each round a random modifier is set.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	CreateConVar("sm_rrm_version", RRM_VERSION, "Random Round Modifier Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	RegAdminCmd("sm_rrmroll", Function_RollModifier, ADMFLAG_GENERIC, "Rerolls a different modifier.");
	
	HookEvent("teamplay_round_start", OnRoundStart, EventHookMode_Post);
	
	/*for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		QueryClientConVar(i, "cl_hud_minmode", ConVarQuery_MinMode);
	}*/
	
	gOnRegOpen = CreateGlobalForward("RRM_OnRegOpen", ET_Ignore);
	gArray = CreateArray();
	
	//Need to check when an active modifier gets unloaded
	CreateTimer(1.0, Timer_OnModifiersUnloaded, _, TIMER_REPEAT);
	
	//AutoExecConfig(true, "rrm", "rrm");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
   CreateNative("RRM_Register", Native_RRM_Register);
   CreateNative("RRM_IsRegOpen", Native_RRM_IsRegOpen);
   RegPluginLibrary("RandomRoundModifier");
   return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	RequestFrame(ExecuteLateLoadModifier, _);
}

public void OnConfigsExecuted()
{
	gIsRegOpen = 1;
	Forward_OnRegOpen();
}

/*public void OnClientPostAdminCheck(int client)
{
	QueryClientConVar(client, "cl_hud_minmode", ConVarQuery_MinMode);	
}*/

/*
public void ConVarQuery_MinMode(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (strlen(cvarValue) > 0)
		gIsMinHUDEnabled[client] = view_as<bool>(StringToInt(cvarValue));
}*/

public void OnMapEnd()
{
	if(gCurrentModifier != null)
	{
		gCurrentModifier.Reset();
		Handle hForward = view_as<Handle>(gCurrentModifier.ReadCell());
		
		if(GetForwardFunctionCount(hForward) == 0)
		{
			delete hForward;
			int index = gArray.FindValue(gCurrentModifier);
			delete gCurrentModifier;
			gArray.Erase(index);
		}
		
		Call_StartForward(hForward);
		Call_PushCell(false);
		Call_PushFloat(0.0);
		Call_Finish();
	}
	gCurrentModifier = null;
}

public Action Timer_OnModifiersUnloaded(Handle timer)
{
	if(gCurrentModifier != null)
	{
		gCurrentModifier.Reset();
		Handle hForward = view_as<Handle>(gCurrentModifier.ReadCell());
		
		if(!GetForwardFunctionCount(hForward))
		{
			delete hForward;
			int index = gArray.FindValue(gCurrentModifier);
			delete gCurrentModifier;
			gArray.Erase(index);
			
			CPrintToChatAll("{cyan}[RRM] {orange}An active modifier was unloaded, picking a new modifier.");
			
			do {
				if(!gArray.Length)
				{
					LogError("[RRM] Error: No active modifiers have been loaded to core.");
					CPrintToChatAll("{cyan}[RRM] {red}Error: {orange}No active modifiers have been loaded to core.");
					return Plugin_Continue;
				}
			} while (GetRandomModifier());
		}
	}
	//Not the best way i guess to detect a sub plugin from unloading
	if(gArray.Length > 0)
	{
		for (int i = gArray.Length - 1; i >= 0; i--)
		{
			DataPack hPack = gArray.Get(i);
			hPack.Reset();
			Handle hForward = view_as<Handle>(hPack.ReadCell());
			if(!GetForwardFunctionCount(hForward))
			{
				delete hForward;
				delete hPack;
				gArray.Erase(i);
			}
		}
	}
	return Plugin_Continue;
}

public Action Function_RollModifier(int client, int args)
{
	//PrintToChat(client, "array size: %d", gArray.Length);
	if(!RollModifiers())
	{
		CReplyToCommand(client, "{cyan}[RRM] {red}Error: {orange}No active modifiers have been loaded to core.");
	}
	return Plugin_Handled;
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(!RollModifiers())
	{
		LogError("[RRM] Error: No active modifiers have been loaded to core.");
		CPrintToChatAll("{cyan}[RRM] {red}Error: {orange}No active modifiers have been loaded to core.");
	}
	return Plugin_Continue;
}

//If this plugin is reloaded during game, get a new modifier
public void ExecuteLateLoadModifier(any val)
{
	if(gCurrentModifier == null)
	{
		if(!RollModifiers())
		{
			LogError("[RRM] Error: No active modifiers have been loaded to core.");
			CPrintToChatAll("{cyan}[RRM] {red}Error: {orange}No active modifiers have been loaded to core.");
		}
	}
}

int RollModifiers()
{
	do {
		if(!gArray.Length)
		{
			return 0;
		}
		
		if(gCurrentModifier != null)
		{
			gCurrentModifier.Reset();
			Handle hForward = view_as<Handle>(gCurrentModifier.ReadCell());
			
			//Check if active sub-plugin was unloaded
			if(!GetForwardFunctionCount(hForward))
			{
				delete hForward;
				int index = gArray.FindValue(gCurrentModifier);
				delete gCurrentModifier;
				gArray.Erase(index);
				continue;
			}
			
			Call_StartForward(hForward);
			Call_PushCell(false);
			Call_PushFloat(0.0);
			Call_Finish();
		}
	} while (GetRandomModifier());
	return 1;
}

int GetRandomModifier()
{
	int randmod = GetRandomInt(0, gArray.Length - 1);
	DataPack hPack = gArray.Get(randmod);
	hPack.Reset();
	
	Handle hForward = view_as<Handle>(hPack.ReadCell());
	
	float min = hPack.ReadFloat();
	float max = hPack.ReadFloat();
	
	bool negate = view_as<bool>(hPack.ReadCell());
	
	char sPluginName[MAX_PLUGIN_LENGTH];
	hPack.ReadString(sPluginName, sizeof(sPluginName));
	
	char sModifierName[MAX_PLUGIN_LENGTH];
	hPack.ReadString(sModifierName, sizeof(sModifierName));	
	
	//Checks whether the sub-plugin selected was unloaded and removes it from array
	//timer does this already but this is a backup just incase this is executed first before the timer
	if(!GetForwardFunctionCount(hForward))
	{
		delete hForward;
		delete hPack;
		gArray.Erase(randmod);
		return 1;
	}
	
	gCurrentModifier = hPack;
	
	float rand;
	if(!min && max)
		rand = max;
	else if(min && !max)
		rand = min;
	else if(!min && !max)
		rand = 0.0;
	else
		rand = GetRandomFloat(min, max);
	
	if(negate)
	{
		if(GetRandomInt(0,1) == 1)
			rand = -(rand);
	}
		
	/*char message[MAX_STRING_LENGTH]; NO LONGER USING
	if(rand == 0.0)
		Format(message, sizeof(message), "%s[RRM] %s%s modifier is now set to active.", GREEN, DEFAULT, sModifierName);
	else
		Format(message, sizeof(message), "%s[RRM] %s%s modifier is now set to %.0f%%%%.", GREEN, DEFAULT, sModifierName, rand*100);
		
	RRM_PrintMsg(message, "leaderboard_streak", 0, 3);
	*/
	
	if(rand == 0.0)
		CPrintToChatAll("{cyan}[RRM] {orange}%s modifier is now set to active", sModifierName);
	else
		CPrintToChatAll("{cyan}[RRM] {orange}%s modifier is now set to %.0f%%", sModifierName, rand*100);
	
	Call_StartForward(hForward);
	Call_PushCell(true);
	Call_PushFloat(rand);
	Call_Finish();
	return 0;
}

//Natives
public int Native_RRM_Register(Handle plugin, int numParams)
{
	char sPluginName[MAX_PLUGIN_LENGTH];
	GetPluginFilename(plugin, sPluginName, sizeof(sPluginName));
	
	if(!gIsRegOpen)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s is trying to register plugin late-loaded, plugin must use native RRM_IsRegOpen and forward RRM_OnRegOpen. Read example plugin.", sPluginName);
		return 0;
	}
	char sModifierName[MAX_PLUGIN_LENGTH];
	GetNativeString(1, sModifierName, sizeof(sModifierName));
	float min = GetNativeCell(2);
	float max = GetNativeCell(3);
	
	if(min < 0 || max < 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "%s is trying to set the min/max value as a negative. This can not happen!", sPluginName);
		return 0;
	}
	
	bool negate = view_as<bool>(GetNativeCell(4));
	
	Handle hForward = CreateForward(ET_Ignore, Param_Cell, Param_Float);
	AddToForward(hForward, plugin, GetNativeFunction(5));
	
	DataPack hPack = new DataPack();
	hPack.WriteCell(hForward);
	hPack.WriteFloat(min);
	hPack.WriteFloat(max);
	hPack.WriteCell(view_as<int>(negate));
	hPack.WriteString(sPluginName);
	hPack.WriteString(sModifierName);
	gArray.Push(hPack);
	
	return 1;
}

public int Native_RRM_IsRegOpen(Handle plugin, int numParams)
{
	return gIsRegOpen;
}

//Forwards
void Forward_OnRegOpen()
{
	if(GetForwardFunctionCount(gOnRegOpen) < 1)
		return;
		
	Call_StartForward(gOnRegOpen);
	Call_Finish();
}

//Print function
/*
void RRM_PrintMsg(char[] message, char[] icon, int color, int repeat)
{
	static UserMsg HudNotifyCustom = INVALID_MESSAGE_ID;
	if(HudNotifyCustom == INVALID_MESSAGE_ID)
	{
		HudNotifyCustom = GetUserMessageId("HudNotifyCustom");
	}
	int[] targets = new int[MaxClients];
	int count;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		targets[count] = i;
		count++;
		
		char tmessage[MAX_STRING_LENGTH];
		strcopy(tmessage, sizeof(tmessage), message);
		ReplaceString(tmessage, sizeof(tmessage), "%%", "%", false);
		if(gIsMinHUDEnabled[i])
		{
			CPrintToChat(i, "%s", tmessage);
		}
	}
	if(count)
	{
		ReplaceString(message, MAX_STRING_LENGTH, GREEN, "", false);
		ReplaceString(message, MAX_STRING_LENGTH, DEFAULT, "", false);
		Handle bf = StartMessageEx(HudNotifyCustom, targets, count);
		BfWriteString(bf, message);
		BfWriteString(bf, icon);
		BfWriteByte(bf, color);
		EndMessage();
		
		if(repeat > 0)
		{
			DataPack hPack;
			CreateDataTimer(1.0, Timer_RepeatHUD, hPack);
			hPack.WriteString(message);
			hPack.WriteString(icon);
			hPack.WriteCell(color);
			hPack.WriteCell(repeat);
		}
	}
}

public Action Timer_RepeatHUD(Handle timer, DataPack hPack)
{
	hPack.Reset();
	char message[MAX_STRING_LENGTH];
	char icon[MAX_STRING_LENGTH];
	hPack.ReadString(message, sizeof(message));
	hPack.ReadString(icon, sizeof(icon));
	int color = hPack.ReadCell();
	int repeat = hPack.ReadCell() - 1;
	RRM_PrintMsg(message, icon, color, repeat);
}*/