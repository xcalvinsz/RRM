/*	
 *	============================================================================
 *	
 *	[RRM] Explosive Headshots Modifier
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

#define RRM_VERSION "1.0"

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int gEnabled = 0;
ConVar cDamage = null, cRadius = null;
int gDamage = 0, gRadius = 0;

public Plugin myinfo = 
{
	name = "[RRM] Explosive Headshots Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that sets off an explosion on a headshot.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cDamage = CreateConVar("rrm_exphs_damage", "30", "Damage the explosion will do.");
	cRadius = CreateConVar("rrm_exphs_radius", "50", "Radius of the explosion damage.");
	
	cDamage.AddChangeHook(OnConvarChanged);
	cRadius.AddChangeHook(OnConvarChanged);
	
	gDamage = cDamage.IntValue;
	gRadius = cRadius.IntValue;
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_exphs", "rrm");
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Explosive Headshot", 0.0, 0.0, false, RRM_Callback_Explode);
}

public void OnConvarChanged(Handle convar, char[] oldValue, char[] newValue)
{
	if (StrEqual(oldValue, newValue, true))
		return;
		
	float fNewValue = StringToFloat(newValue);
	
	if(convar == cDamage)
		gDamage = RoundFloat(fNewValue);
	else if(convar == cRadius)
		gRadius = RoundFloat(fNewValue);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_Explode(bool enable, float value)
{
	gEnabled = enable;
	return gEnabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!gEnabled)
		return Plugin_Continue;
		
	if(damagecustom == TF_CUSTOM_HEADSHOT)
	{
		float pos[3];
		GetClientAbsOrigin(victim, pos);
		CreateExplosion(attacker, gDamage, gRadius, pos);
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