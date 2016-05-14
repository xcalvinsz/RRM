/*	
 *	============================================================================
 *	
 *	[TF2] RRM Speed Modifier
 *	Current Version: 0.01 Beta
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

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define MIN 0.5
#define MAX 2.0

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int g_Enabled = 0;
float g_baseSpeed[MAXPLAYERS + 1] = {0.0, ...};
float g_Speed = 0.0;

public Plugin myinfo = 
{
	name = "[TF2] RRM Speed Modifier",
	author = PLUGIN_AUTHOR,
	description = "Modifier that changes the the speed of players.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	HookEvent("player_changeclass", OnPlayerClassChanged, EventHookMode_Post);
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
	RRM_Register("Players' movement speed", MIN, MAX, false, RRM_Callback_Speed);
}

public void OnClientPostAdminCheck(int i)
{
	if(!g_Enabled)
		return;
	TF2Attrib_SetByDefIndex(i, 107, g_Speed);
	SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", g_baseSpeed[i]*g_Speed);
}

public Action OnPlayerClassChanged(Handle event, const char[] name, bool dontBroadcast)
{
	if(!g_Enabled)
		return Plugin_Continue;
	int i = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2Attrib_SetByDefIndex(i, 107, g_Speed);
	SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", g_baseSpeed[i]*g_Speed);
	return Plugin_Continue;
}

public int RRM_Callback_Speed(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
	{
		g_Speed = value;
		SetSpeed();
	}
	else
	{
		SetBaseSpeed();
	}
	return g_Enabled;
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
				g_baseSpeed[i] = 400.0;
			case TFClass_Soldier:
				g_baseSpeed[i] = 240.0;
			case TFClass_DemoMan:
				g_baseSpeed[i] = 280.0;
			case TFClass_Heavy:
				g_baseSpeed[i] = 230.0;
			case TFClass_Medic:
				g_baseSpeed[i] = 320.0;
			default:
				g_baseSpeed[i] = 300.0;
		}
		TF2Attrib_SetByDefIndex(i, 107, g_Speed);
		SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", g_baseSpeed[i]*g_Speed);
	}
}

void SetBaseSpeed()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		TF2Attrib_RemoveByDefIndex(i, 107);
		SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", g_baseSpeed[i]);
	}
}