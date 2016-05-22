/*	
 *	============================================================================
 *	
 *	[RRM] Melee Only Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that force everyone to melee.
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

public Plugin myinfo = 
{
	name = "[RRM] Melee Only Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that force everyone to melee.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_meleeonly", "rrm");
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
	if(!gEnabled)
		return Plugin_Continue;
	int i = GetClientOfUserId(GetEventInt(event, "userid"));
	StripPlayer(i);
	return Plugin_Continue;
}

public int RRM_Callback_MeleeOnly(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
		EnableMeleeOnly();
	else
		DisableMeleeOnly();
	return gEnabled;
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