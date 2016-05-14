/*	
 *	============================================================================
 *	
 *	[TF2] RRM Explosive Headshots
 *	Current Version: 0.01 Beta
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that sets off an explosion on a headshot.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define DAMAGE 30
#define RADIUS 50

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
	name = "[TF2] RRM Explosive Headshots",
	author = PLUGIN_AUTHOR,
	description = "Modifier that sets off an explosion on a headshot.",
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
	RRM_Register("Explosive Headshot", 0.0, 0.0, false, RRM_Callback_Explode);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_Explode(bool enable, float value)
{
	g_Enabled = enable;
	return g_Enabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!g_Enabled)
		return Plugin_Continue;
		
	if(damagecustom == TF_CUSTOM_HEADSHOT)
	{
		float pos[3];
		GetClientAbsOrigin(victim, pos);
		CreateExplosion(attacker, DAMAGE, RADIUS, pos);
	}
	return Plugin_Continue;
}

void CreateExplosion(int owner, int damage, int radius, float pos[3])
{
	int entity = CreateEntityByName("env_explosion");
	if(!IsValidEntity(entity))
		return;

	SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", owner);
	SetEntProp(entity, Prop_Data, "m_iMagnitude", damage);
	SetEntProp(entity, Prop_Data, "m_iRadiusOverride", radius);
	SetEntProp(entity, Prop_Send, "m_iTeamNum", GetClientTeam(owner));

	TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Explode");
	AcceptEntityInput(entity, "Kill");
}