#include <sourcemod>
#include <cstrike>
#include <dhooks>

// Hooking the ConVar_SetFloat function
Handle g_hConVar_SetFloat;
ConVar g_pCl_YawSpeed;

// Hook function for ConVar_SetFloat
public MRESReturn ConVar_SetFloat(Handle hParams)
{
    any thisConVar = GetParamObject(hParams, 0); // Changed void* to any
    float value = GetParamFloat(hParams, 1);

    if (thisConVar == view_as<any>(g_pCl_YawSpeed)) // Changed void* to any
    {
        return MRES_Ignore; // Allow setting the value if it's cl_yawspeed
    }

    return MRES_Supercede; // Block setting the value for other ConVars
}

// Command handler function for the !yawspeed command
public Action SetYawSpeedCommand(int client, int args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    int new_yaw_speed = 0;
    new_yaw_speed = GetClientCmdArgInt(client, 1);

    if (new_yaw_speed > 0)
    {
        SetClientConVar(client, "cl_yawspeed", new_yaw_speed);
        ClientPrint(client, print_chat, "Your yaw speed has been set to %d\n", new_yaw_speed);
    }
    else
    {
        ClientPrint(client, print_chat, "Invalid yaw speed value\n");
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
    g_hConVar_SetFloat = DHookCreateDetour(addrSetFloat, ConVar_SetFloat, HookType_Raw, CallingConvention_This);
    DHookEnableDetour(g_hConVar_SetFloat, true);

    // Register the SetYawSpeedCommand function as a chat command
    RegAdminCmd("sm_yawspeed", SetYawSpeedCommand, ADMFLAG_GENERIC, "Set your yaw speed");
}

// Plugin end function
public void OnPluginEnd()
{
    // Disable and destroy the hook when the plugin ends
    if (g_hConVar_SetFloat != null)
    {
        DHookEnableDetour(g_hConVar_SetFloat, false);
        CloseHandle(g_hConVar_SetFloat);
    }
}
