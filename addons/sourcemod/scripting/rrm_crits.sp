/*	
 *	============================================================================
 *	
 *	[RRM] Critical Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that changes critical chance.
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
ConVar cMin = null, cMax = null;
float gMin = 0.0, gMax = 0.0;

public Plugin myinfo = 
{
	name = "[RRM] Critical Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that changes critical chance.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cMin = CreateConVar("rrm_crits_min", "0.5", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_crits_max", "1.0", "Maximum value for the random number generator.");
	
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_crits", "rrm");
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Critical hits", gMin, gMax, false, RRM_Callback_Crits);
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

public int RRM_Callback_Crits(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
		gChance = value;
	return gEnabled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	if(!gEnabled)
		return Plugin_Continue;
	if(gChance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
		result = true;
	else
		result = false;
	return Plugin_Changed;
}