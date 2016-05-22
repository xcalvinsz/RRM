/*	
 *	============================================================================
 *	
 *	[RRM] Critical Modifier Example
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Simple example plugin that will enable/disable and modifies critical chance.
 *
 *	============================================================================
 */
#pragma semicolon 1

#define RRM_VERSION "0.01"

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
	//RRM_AUTHOR and RRM_URL is defined in .inc
	//RRM_VERSION is defined in this plugin
	name = "[RRM] Critical Modifier Example",
	author = RRM_AUTHOR,
	description = "Simple example plugin that will enable/disable and modifies critical chance.",
	version = RRM_VERSION,
	url = RRM_URL
};

public void OnPluginStart()
{
	//These are our convars
	cMin = CreateConVar("rrm_crits_min", "0.5", "Minimum value for the random number generator.");
	cMax = CreateConVar("rrm_crits_max", "1.0", "Maximum value for the random number generator.");
	
	//We hook them if user decides to change them and forward them to OnConvarChanged
	cMin.AddChangeHook(OnConvarChanged);
	cMax.AddChangeHook(OnConvarChanged);
	
	//We cache the variables to gMin and gMax
	gMin = cMin.FloatValue;
	gMax = cMax.FloatValue;
	
	//RRM_IsRegOpen will return true if we can register modifiers
	//The purpose of this is to ensure we do not encounter problems on late-load
	//This must always be executed
	//If registering is open, then we run RegisterModifiers() which will run our function we defined below
	if(RRM_IsRegOpen())
		RegisterModifiers();
	
	//We create a config with out convars called rrm_crits.cfg to cfg/rrm folder
	AutoExecConfig(true, "rrm_crits", "rrm");
}

//RRM_OnRegOpen() is our forward
//If RRM_IsRegOpen did not succeed then RRM_OnRegOpen will be forwarded to here when it does open
public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

//On this function we register this modifier with RRM_Register
//First parameter is the name, this will be used and printed on round start
//gMin and gMax are the convar values, the random number generator will pick a value between them and return it to callback function
//The 4th argument is negate which IF true will negate the random value between min and max, mostly you won't need it
//If min = 0.5 and max is 1.0 and negate is true then results can be -1.0 to -0.5 AND 0.5 to 1.0
//The last argument will be the callback function, it will be the function that the core will call to this plugin
void RegisterModifiers()
{
	RRM_Register("Critical hits", gMin, gMax, false, RRM_Callback_Crits);
}

//Our convar changed callback
//We set our cache values to the updated one whenever a convar is changed
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

//This is our callback function that the core plugin will call
//Parameter will be true if core is setting this modifier active, false to turn off
//Value is return of random value between min and max values that you passed in RRM_Register
//If value is negative that is because you passed false in the negate parameter in RRM_Register
public int RRM_Callback_Crits(bool enable, float value)
{
	//Here we store our global enable variable to equal enable
	//enable is what the core plugin will give depending on whether or not to turn on or off
	//value will be the result between min and max
	gEnabled = enable;
	if(gEnabled)
	{
		//we store the value to our global variable to use later
		gChance = value;
	}
	return gEnabled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	//If core enables plugin, this will enable
	if(!gEnabled)
		return Plugin_Continue;
	//Here we use the stored variable and do some calculations to get crit chance
	if(gChance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
		result = true;
	else
		result = false;
	return Plugin_Changed;
}