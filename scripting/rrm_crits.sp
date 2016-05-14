/*	
 *	============================================================================
 *	
 *	[TF2] RRM Critical Modifier
 *	Current Version: 0.01 Beta
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that chances the critical chance from shots.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"
#define MIN 0.5
#define MAX 1.0

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
	name = "[TF2] RRM Critical Modifier",
	author = PLUGIN_AUTHOR,
	description = "Modifier that chances the critical chance from shots.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	if(RRM_IsRegOpen())
		RegisterModifiers();
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Critical hits", MIN, MAX, false, RRM_Callback_Crits);
}

public int RRM_Callback_Crits(bool enable, float value)
{
	g_Enabled = enable;
	if(g_Enabled)
	{
		g_Chance = value;
	}
	return g_Enabled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	if(!g_Enabled)
		return Plugin_Continue;
	if(g_Chance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
		result = true;
	else
		result = false;
	return Plugin_Changed;
}