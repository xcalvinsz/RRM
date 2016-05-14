/*	
 *	============================================================================
 *	
 *	[TF2] RRM Melee Only
 *	Current Version: 0.01 Beta
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that force everyone to melee only.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int g_Enabled = 0;

public Plugin myinfo = 
{
	name = "[TF2] RRM Melee Only",
	author = PLUGIN_AUTHOR,
	description = "Modifier that force everyone to melee only.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
}

public void OnPluginEnd()
{
	DisableMeleeOnly();
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Melee only", 0.0, 0.0, false, RRM_Callback_MeleeOnly);
}

public Action OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if(!g_Enabled)
		return Plugin_Continue;
	int i = GetClientOfUserId(GetEventInt(event, "userid"));
	StripPlayer(i);
	return Plugin_Continue;
}

public int RRM_Callback_MeleeOnly(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
		EnableMeleeOnly();
	else
		DisableMeleeOnly();
	return g_Enabled;
}

void EnableMeleeOnly()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		StripPlayer(i);
	}
}

void DisableMeleeOnly()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		UnstripPlayer(i);
	}
}


void StripPlayer(int i)
{
	TF2Attrib_SetByDefIndex(i, 77, 0.0);
	TF2Attrib_SetByDefIndex(i, 79, 0.0);
	TF2Attrib_SetByDefIndex(i, 81, 0.0);
	
	for (int j = 0; j < 2; j++)
	{
		int weapon = GetPlayerWeaponSlot(i, j);
		if(!IsValidEntity(weapon))
			continue;
		TF2Attrib_SetByDefIndex(weapon, 3, 0.0);
	}
	
	TF2_RegeneratePlayer(i);
	int weapon = GetPlayerWeaponSlot(i, 2);
	if(!IsValidEntity(weapon))
		return;
	EquipPlayerWeapon(i, weapon);
}

void UnstripPlayer(int i)
{
	TF2Attrib_RemoveByDefIndex(i, 77);
	TF2Attrib_RemoveByDefIndex(i, 79);
	TF2Attrib_RemoveByDefIndex(i, 81);
	
	for (int j = 0; j < 2; j++)
	{
		int weapon = GetPlayerWeaponSlot(i, j);
		if(!IsValidEntity(weapon))
			continue;
		TF2Attrib_RemoveByDefIndex(weapon, 3);
	}
	
	TF2_RegeneratePlayer(i);
	EquipPlayerWeapon(i, GetPlayerWeaponSlot(i, 0));
}