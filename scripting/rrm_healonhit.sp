/*	
 *	============================================================================
 *	
 *	[TF2] RRM Heal on hit
 *	Current Version: 0.01 Beta
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that heals players by how much damage they did to others.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define MIN 0.05
#define MAX	0.20

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int g_Enabled = 0;
float g_Heal = 0.0;

public Plugin myinfo = 
{
	name = "[TF2] RRM Heal on hit",
	author = PLUGIN_AUTHOR,
	description = "Modifier that heals players by how much damage they did to others.",
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
	RRM_Register("Heal on hit", MIN, MAX, false, RRM_Callback_HealOnHit);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_HealOnHit(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
	{
		g_Heal = value;
	}
	return g_Enabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!g_Enabled)
		return Plugin_Continue;
	int health = GetEntProp(attacker, Prop_Data, "m_iHealth") + RoundFloat(damage * g_Heal);
	SetEntProp(attacker, Prop_Data, "m_iHealth", health);
	
	return Plugin_Continue;
}