#include <sourcemod>

// Pointers to the functions we need to use
cell g_pfnGetClientCmdArgInt;
cell g_pfnClientPrint;

// Function signatures for the functions we need to use
function int (GetClientCmdArgIntFn)(int, int);
function void (ClientPrintFn)(int, int, const char, ...);

// Command handler function for the !yawspeed command
public Action SetYawSpeedCommand(int client, int args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    // Get the first argument passed to the command as an integer
    int new_yaw_speed = ((GetClientCmdArgIntFn) g_pfnGetClientCmdArgInt)(client, 1);

    // Set the client's cl_yawspeed convar to the new value
    if (new_yaw_speed > 0)
    {
        ServerCommand("sm_csay \"!yawspeed %d\"\n", new_yaw_speed);
        ((ClientPrintFn) g_pfnClientPrint)(client, print_chat, "Your yaw speed has been set to %d\n", new_yaw_speed);
    }
    else
    {
        ((ClientPrintFn) g_pfnClientPrint)(client, print_chat, "Invalid yaw speed value\n");
    }

    return Plugin_Handled;
}

// Plugin initialization function
public void OnPluginStart()
{
    // Find the addresses of the functions we need to use using signature scanning
    g_pfnGetClientCmdArgInt = FindFunction("engine", "GetClientCmdArgInt");
    g_pfnClientPrint = FindFunction("engine", "ClientPrint");

    // Register the SetYawSpeedCommand function as a chat command
    RegAdminCmd("sm_yawspeed", SetYawSpeedCommand, ADMFLAG_GENERIC, "Set your yaw speed");
}
