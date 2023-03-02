#include <sourcemod>

// Pointers to the functions we need to use
cell g_pfnGetClientCmdArgInt;
cell g_pfnSetClientConVar;
cell g_pfnClientPrint;

// Function signatures for the functions we need to use
typedef int (GetClientCmdArgIntFn)(int, int);
typedef void (SetClientConVarFn)(int, const char , const char);
typedef void (ClientPrintFn)(int, int, const char, ...);

// Command handler function for the !yawspeed command
stock Action:SetYawSpeedCommand(int client)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    // Get the first argument passed to the command as an integer
    int new_yaw_speed = ((GetClientCmdArgIntFn) g_pfnGetClientCmdArgInt)(client, 1);

    // Set the client's cl_yawspeed convar to the new value
    if (new_yaw_speed > 0)
    {
        ((SetClientConVarFn) g_pfnSetClientConVar)(client, "cl_yawspeed", format("%d", new_yaw_speed));
        ((ClientPrintFn) g_pfnClientPrint)(client, print_chat, "Your yaw speed has been set to %d\n", new_yaw_speed);
    }
    else
    {
        ((ClientPrintFn) g_pfnClientPrint)(client, print_chat, "Invalid yaw speed value\n");
    }

    return Plugin_Handled;
}

// Plugin initialization function
public void PluginInit()
{
    // Find the addresses of the functions we need to use using signature scanning
    g_pfnGetClientCmdArgInt = FindFunction("engine", "GetClientCmdArgInt");
    g_pfnSetClientConVar = FindFunction("engine", "SetClientConVar");
    g_pfnClientPrint = FindFunction("engine", "ClientPrint");

    // Register the SetYawSpeedCommand function as a chat command
    RegAdminCmd("sm_yawspeed", "Set your yaw speed", ADMFLAG_GENERIC, SetYawSpeedCommand);
}