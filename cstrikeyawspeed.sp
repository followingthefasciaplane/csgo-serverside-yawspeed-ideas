#include <sourcemod>
#include <cstrike>

// Command handler function for the !yawspeed command
stock Action:SetYawSpeedCommand(int client)
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
public void PluginInit()
{
    RegAdminCmd("sm_yawspeed", "Set your yaw speed", ADMFLAG_GENERIC, SetYawSpeedCommand);
}