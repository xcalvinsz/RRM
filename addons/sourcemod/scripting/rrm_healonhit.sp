/*	
 *	============================================================================
 *	
 *	[RRM] Heal on hit Modifier
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

#define RRM_VERSION "1.0"

#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <rrm>

#pragma newdecls required

int gEnabled = 0;
float gHeal = 0.0;
ConVar cMin = null, cMax = null;
float gMin = 0.0, gMax = 0.0;

public Plugin myinfo = 
{
	name = "[RRM] Heal on hit Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that heals players by how much damage they did to others.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cMin = CreateConVar("rrm_healonhit_min", "0.05", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_healonhit_max", "0.2", "Maximum value for the random number generator.");
	
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	
	for (int i = 1; i < MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_healonhit", "rrm");
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Heal on hit", gMin, gMax, false, RRM_Callback_HealOnHit);
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

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
}

public int RRM_Callback_HealOnHit(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
	{
		gHeal = value;
	}
	return gEnabled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!gEnabled)
		return Plugin_Continue;
	int health = GetEntProp(attacker, Prop_Data, "m_iHealth") + RoundFloat(damage * gHeal);
	SetEntProp(attacker, Prop_Data, "m_iHealth", health);
	
	return Plugin_Continue;
}