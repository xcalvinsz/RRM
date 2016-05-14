#if defined _rrm_included
 #endinput
#endif
#define _rrm_included

public SharedPlugin:__pl_rrm = {
	name = "RandomRoundModifier",
	file = "rrm.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_rrm_SetNTVOptional()
{
	MarkNativeAsOptional("RRM_Register");
	MarkNativeAsOptional("RRM_IsRegOpen");
}
#endif

functag RRMTag public(bool:enable, Float:value);

/**
 * Registers the modifier into the core, MUST use RRM_Unregister() OnPluginEnd() forward
 *
 * @char str    	Name of the modifier that will be printed on round start
 * @float min    	The minimum value that can be set (Set to 0.0 to ignore, value must be positive)
 * @float max    	The maximum value that can be set (Set to 0.0 to ignore, value must be positive)
 					If min is 1.0 and max is 0.0 then the result will always be 1.0
 					If max is 2.0 and min is 0.0 then the result will always be 2.0
 					If min and max are both 0.0 then these parameters will be ignored
 * @negate			Determines whether the random between min and max will be negated
 					(E.G useful if you want to determine whether to reduce/increase something)
 * @Function func   The return function callback that the core plugin will call
 * @return        	Returns 1 if successful register, 0 otherwise
 */
native int RRM_Register(char[] str, float min, float max, bool negate, RRMTag:func);

/**
 * Registers the modifier into the core
 *
 * @return		Returns 1 if registering is open, 0 otherwise
 */
native int RRM_IsRegOpen();

/**
 * This forward will fire when RRM is ready to accept registrating
 * RRM_Register should ALWAYS be executed in this forward.
 */
forward RRM_OnRegOpen();