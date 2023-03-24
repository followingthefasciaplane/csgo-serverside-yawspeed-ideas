#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <dhooks>

// Hooking the ConVar_SetFloat function
Handle g_hConVar_SetFloat;
ConVar g_pCl_YawSpeed;

// Hook function for ConVar_SetFloat
public MRESReturn ConVar_SetFloat(Handle hParams)
{
    ConVar thisConVar = view_as<ConVar>(DHookGetParamObjectPtrVar(hParams, 0, 0, ObjectValueType_Int));
    float value = view_as<float>(DHookGetParam(hParams, 1));

    if (thisConVar == g_pCl_YawSpeed)
    {
        return MRES_Ignored; // Allow setting the value if it's cl_yawspeed
    }

    return MRES_Supercede; // Block setting the value for other ConVars
}

// Command handler function for the !yawspeed command
public Action SetYawSpeedCommand(int client, int args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    int new_yaw_speed = 0;
    char arg[32];
    GetCmdArg(1, arg, sizeof(arg));
    new_yaw_speed = StringToInt(arg);

    if (new_yaw_speed > 0)
    {
        SetEntPropFloat(client, Prop_Send, "m_flCustomAutoExposureMin", new_yaw_speed);
        PrintToChat(client, "Your yaw speed has been set to %d\n", new_yaw_speed);
    }
    else
    {
        PrintToChat(client, "Invalid yaw speed value\n");
    }

    return Plugin_Handled;
}

// Plugin initialization function
public void OnPluginStart()
{
    // Find the cl_yawspeed ConVar
    g_pCl_YawSpeed = FindConVar("cl_yawspeed");

    // Find and hook the ConVar_SetFloat function
    Address addrSetFloat = FindSendPropInfo("ConVar", "SetFloat");
	g_hConVar_SetFloat = DHookCreateDetour(addrSetFloat, Hook_Pre, ReturnType_Void, ThisPointer_Address);
    DHookAddParam(g_hConVar_SetFloat, HookParamType_ObjectPtr);
    DHookAddParam(g_hConVar_SetFloat, HookParamType_Float);
    DHookEnableDetour(g_hConVar_SetFloat, true, ConVar_SetFloat);

    // Register the SetYawSpeedCommand function as a chat command
    RegAdminCmd("sm_yawspeed", SetYawSpeedCommand, ADMFLAG_GENERIC, "Set your yaw speed");
}

// Plugin end function
public void OnPluginEnd()
{
    // Disable and destroy the hook when the plugin ends
    if (g_hConVar_SetFloat != null)
    {
        DHookEnableDetour(g_hConVar_SetFloat, false, ConVar_SetFloat);
        CloseHandle(g_hConVar_SetFloat);
    }
}
