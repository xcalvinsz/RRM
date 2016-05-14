/*	
 *	============================================================================
 *	
 *	[TF2] RRM Example
 *
 *	Written by Tak (Chaosxk)
 *	https://forums.alliedmods.net/member.php?u=87026
 *
 *	This plugin is FREE and can be distributed to anyone.  
 *	If you have paid for this plugin, get your money back.
 *	
 *	Simple example plugin that will enable/disable and modifies critical chance
 *
 *	============================================================================
 */
#pragma semicolon 1

#define PLUGIN_AUTHOR "Tak (Chaosxk)"
#define PLUGIN_VERSION "0.01"

//These defined values will be used to pass into the core
//The core will return these values back to our callback function for use to use
//The random value generated will be between 0.5-1.0 (50%-100% chance)
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
	name = "[TF2] RRM Critical Modifier Example",
	author = PLUGIN_AUTHOR,
	description = "Modifier example of critical chance.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	//RRM_IsRegOpen will return true if we can register modifiers
	//The purpose of this is to ensure we do not encounter problems on late-load
	//This must always be executed
	//If registering is open, then we run RegisterModifiers() which will run our function we defined below
	if(RRM_IsRegOpen())
		RegisterModifiers();
}

//RRM_OnRegOpen() is our forward
//If RRM_IsRegOpen did not succeed then RRM_OnRegOpen will be forwarded to here when it does open
public int RRM_OnRegOpen()
{
	RegisterModifiers();
}

//On this function we register this modifier with RRM_Register
//First parameter is the name, this will be used and printed on round start
//MIN and MAX were the defined values on top that we want our returned value to be between
//The 4th argument is negate which IF true will negate the random value between min and max, mostly you won't need it
//If min = 0.5 and max is 1.0 and negate is true then results can be -1.0 to -0.5 AND 0.5 to 1.0
//The last argument will be the callback function, it will be the function that the core will call to this plugin
void RegisterModifiers()
{
	RRM_Register("Critical hits", MIN, MAX, false, RRM_Callback_Crits);
}

//This is our callback function
//Parameter will be true if core is setting this modifier active, false to turn off
//Value is return of random value between min and max values that you passed in RRM_Register
//If value is negative that is because you passed false in the negate parameter in RRM_Register
public int RRM_Callback_Crits(bool enable, float value)
{
	//Here we store our global enable variable to equal enable
	//enable is what the core plugin will give depending on whether or not to turn on or off
	//value will be the result between min and max
	g_Enabled = enable;
	if(g_Enabled)
	{
		//we store the value to our global variable to use later
		g_Chance = value;
	}
	return g_Enabled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	//If core enables plugin, this will enable
	if(!g_Enabled)
		return Plugin_Continue;
	//Here we use the stored variable and do some calculations to get crit chance
	if(g_Chance > GetRandomFloat(GetRandomFloat(0.0, 1.0)))
		result = true;
	else
		result = false;
	return Plugin_Changed;
}