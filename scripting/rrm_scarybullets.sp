/*	
 *	============================================================================
 *	
 *	[TF2] RRM Scary Bullets
 *	Current Version: 0.01 Beta
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

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define MIN 0.1
#define MAX	1.0
#define DURATION 1.5

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int g_Enabled = 0;
float g_Chance = 0.0;

public Plugin myinfo = 
{
	name = "[TF2] RRM Scary Bullets",
	author = PLUGIN_AUTHOR,
	description = "Modifier that grants chance of scary bullets.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Scary Bullets", MIN, MAX, false, RRM_Callback_ScaryBullets);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_ScaryBullets(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
	{
		g_Chance = value;
	}
	return g_Enabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!g_Enabled)
		return Plugin_Continue;
	
	if(g_Chance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
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
		TF2_StunPlayer(victim, DURATION, _, TF_STUNFLAGS_GHOSTSCARE, attacker);
	}
	return Plugin_Continue;
}