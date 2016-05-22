/*	
 *	============================================================================
 *	
 *	[RRM] Speed Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that changes the the speed of players.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define RRM_VERSION "1.0"

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int gEnabled = 0;
ConVar cMin = null, cMax = null;
float gMin = 0.0, gMax = 0.0;
float gBaseSpeed[MAXPLAYERS + 1] = {0.0, ...};
float gSpeed = 0.0;

public Plugin myinfo = 
{
	name = "[RRM] Speed Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that changes the the speed of players.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cMin = CreateConVar("rrm_speed_min", "0.5", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_speed_max", "2.0", "Maximum value for the random number generator.");
	
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	
	HookEvent("player_changeclass", OnPlayerClassChanged, EventHookMode_Post);
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_speed", "rrm");
}

public void OnPluginEnd()
{
	SetBaseSpeed();
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Players' movement speed", gMin, gMax, false, RRM_Callback_Speed);
}

public void OnConvarChanged(Handle convar, char[] oldValue, char[] newValue)
{
	if (StrEqual(oldValue, newValue, true))
		return;
		
	float fNewValue = StringToFloat(newValue);
	
	if(convar == cMin)
		gMin = fNewValue;
	else if(convar == cMax)
		gMax = fNewValue;
}

public void OnClientPostAdminCheck(int i)
{
	if(!gEnabled)
		return;
	TF2Attrib_SetByDefIndex(i, 107, gSpeed);
	SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", gBaseSpeed[i]*gSpeed);
}

public Action OnPlayerClassChanged(Handle event, const char[] name, bool dontBroadcast)
{
	if(!gEnabled)
		return Plugin_Continue;
	int i = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2Attrib_SetByDefIndex(i, 107, gSpeed);
	SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", gBaseSpeed[i]*gSpeed);
	return Plugin_Continue;
}

public int RRM_Callback_Speed(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
	{
		gSpeed = value;
		SetSpeed();
	}
	else
		SetBaseSpeed();
	return gEnabled;
}

void SetSpeed()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		switch(TF2_GetPlayerClass(i))
		{
			case TFClass_Scout:		
				gBaseSpeed[i] = 400.0;
			case TFClass_Soldier:
				gBaseSpeed[i] = 240.0;
			case TFClass_DemoMan:
				gBaseSpeed[i] = 280.0;
			case TFClass_Heavy:
				gBaseSpeed[i] = 230.0;
			case TFClass_Medic:
				gBaseSpeed[i] = 320.0;
			default:
				gBaseSpeed[i] = 300.0;
		}
		TF2Attrib_SetByDefIndex(i, 107, gSpeed);
		SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", gBaseSpeed[i]*gSpeed);
	}
}

void SetBaseSpeed()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		TF2Attrib_RemoveByDefIndex(i, 107);
		SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", gBaseSpeed[i]);
	}
}