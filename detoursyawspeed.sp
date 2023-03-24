#include <sourcemod>
#include <cstrike>
#include <detours>

// Detouring the ConVar_SetFloat function
Detour g_pConVar_SetFloat;
ConVar *g_pCl_YawSpeed;

// Detour function for ConVar_SetFloat
void ConVar_SetFloat(void *this, float value)
{
    if (this == g_pCl_YawSpeed)
    {
        // Allow setting the value if it's cl_yawspeed
        g_pConVar_SetFloat.GetOriginalFunction()(this, value);
    }
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

    // Find and detour the ConVar_SetFloat function
    g_pConVar_SetFloat = Detour.Create(g_pCl_YawSpeed, "SetFloat", "ConVar_SetFloat");
    g_pConVar_SetFloat.EnableDetour();

    // Register the SetYawSpeedCommand function as a chat command
    RegAdminCmd("sm_yawspeed", SetYawSpeedCommand, ADMFLAG_GENERIC, "Set your yaw speed");
}

// Plugin end function
public void OnPluginEnd()
{
    // Disable and destroy the detour when the plugin ends
    if (g_pConVar_SetFloat)
    {
        g_pConVar_SetFloat.DisableDetour();
        delete g_pConVar_SetFloat;
    }
}
