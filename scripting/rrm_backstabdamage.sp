/*	
 *	============================================================================
 *	
 *	[TF2] RRM Backstab Damage
 *	Current Version: 0.01 Beta
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that changes backstab damage.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define MIN 0.01
#define MAX	1.5

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int g_Enabled = 0;
float g_Damage = 0.0;

public Plugin myinfo = 
{
	name = "[TF2] RRM Backstab Damage",
	author = PLUGIN_AUTHOR,
	description = "Modifier that changes backstab damage.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if(RRM_IsRegOpen())
		RegisterModifiers1();
		
	for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public int RRM_OnRegOpen()
{
	RegisterModifiers2();
}

void RegisterModifiers1()
{
	PrintToChatAll("1");
	RRM_Register("Backstab damage", MIN, MAX, false, RRM_Callback_Backstab);
}

void RegisterModifiers2()
{
	PrintToChatAll("2");
	RRM_Register("Backstab damage", MIN, MAX, false, RRM_Callback_Backstab);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_Backstab(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
	{
		g_Damage = value;
	}
	return g_Enabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!g_Enabled)
		return Plugin_Continue;
		
	if(damagecustom == TF_CUSTOM_BACKSTAB)
	{
		damage *= g_Damage;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}