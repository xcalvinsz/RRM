/*	
 *	============================================================================
 *	
 *	[RRM] Gravity Modifier
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Modifier that changes players' gravity.
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
float gGravity = 0.0;
ConVar cMin = null, cMax = null;
float gMin = 0.0, gMax = 0.0;

public Plugin myinfo = 
{
	name = "[RRM] Gravity Modifier",
	author = RRM_AUTHOR,
	description = "Modifier that changes players' gravity.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	cMin = CreateConVar("rrm_gravity_min", "0.1", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_gravity_max", "0.5", "Maximum value for the random number generator.");
	
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	
	if(RRM_IsRegOpen())
		RegisterModifiers();
		
	AutoExecConfig(true, "rrm_gravity", "rrm");
}

public void OnPluginEnd()
{
	DisableGravity();
}

public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

void RegisterModifiers()
{
	RRM_Register("Gravity", gMin, gMax, false, RRM_Callback_Gravity);
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

public void OnClientPostAdminCheck(int i)
{
	if(!gEnabled)
		return;
	SetEntityGravity(i, gGravity);
}

public int RRM_Callback_Gravity(bool enable, float value)
{
	gEnabled = enable;
	if(gEnabled)
	{
		gGravity = value;
		EnableGravity();
	}
	else
		DisableGravity();
	return enable;
}

void EnableGravity()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SetEntityGravity(i, gGravity);
	}
}

void DisableGravity()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
		SetEntityGravity(i, 1.0);
	}
}