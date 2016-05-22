/*	
 *	============================================================================
 *	
 *	[RRM] Scary Bullets Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that grants chance of scary bullets.
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
float gChance = 0.0;
ConVar cMin = null, cMax = null, cDuration = null;
float gMin = 0.0, gMax = 0.0, gDuration = 0.0;

public Plugin myinfo = 
{
	name = "[RRM] Scary Bullets Modifer",
	author = RRM_AUTHOR,
	description = "Modifier that grants chance of scary bullets.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cMin = CreateConVar("rrm_scarybullets_min", "0.1", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_scarybullets_max", "1.0", "Maximum value for the random number generator.");
	cDuration = CreateConVar("rrm_scarybullets_duration", "1,5", "Duration scary bullets last on affected players.");
	
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	cDuration.AddChangeHook(OnConvarChanged);
	
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	gDuration = cDuration.FloatValue;
		
	for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_scarybullets", "rrm");
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Scary Bullets", gMin, gMax, false, RRM_Callback_ScaryBullets);
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
	else if(convar == cDuration)
		gDuration = fNewValue;
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_ScaryBullets(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
		gChance = value;
	return gEnabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!gEnabled)
		return Plugin_Continue;
	
	if(gChance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
	{
		if(!(1 <= victim <= MaxClients))
			return Plugin_Continue;
		if(!IsClientInGame(victim))
			return Plugin_Continue;
		if(!(1 <= attacker <= MaxClients))
			return Plugin_Continue;
		if(!IsClientInGame(attacker))
			return Plugin_Continue;
		if(!IsPlayerAlive(victim))
			return Plugin_Continue;
		TF2_StunPlayer(victim, gDuration, _, TF_STUNFLAGS_GHOSTSCARE, attacker);
	}
	return Plugin_Continue;
}