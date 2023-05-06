#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sh_inc>

ConVar g_pCustomYawSpeed;
ArrayList g_PlayerYawSpeeds;

public void OnPluginStart()
{
    // Create custom ConVar
    g_pCustomYawSpeed = CreateConVar("sm_custom_yawspeed", "0", "Custom yaw speed for players", FCVAR_NONE, true, 0.0, true, 10000.0);

    // Initialize player yaw speed array
    g_PlayerYawSpeeds = new ArrayList();

    // Register events and commands
    RegAdminCmd("sm_yawspeed", SetYawSpeedCommand, ADMFLAG_GENERIC, "Set your yaw speed");
    HookEvent("player_spawn", Event_PlayerSpawn);
    SH_ADD_HOOK_MEMFUNC(CBasePlayer, RunCommand, SH_STATIC(OnRunCommand), false);
}

public void OnPluginEnd()
{
    // Cleanup
    delete g_PlayerYawSpeeds;
    SH_REMOVE_HOOK_MEMFUNC(CBasePlayer, RunCommand, SH_STATIC(OnRunCommand), false);
}

public Action SetYawSpeedCommand(int client, int args)
{
    if (!IsClientInGame(client))
        return Plugin_Handled;

    float newYawSpeed = GetCmdArgFloat(1);

    if (newYawSpeed >= 0.0)
    {
        SetClientYawSpeed(client, newYawSpeed);
        PrintToChat(client, "Your yaw speed has been set to %.1f\n", newYawSpeed);
    }
    else
    {
        PrintToChat(client, "Invalid yaw speed value\n");
    }

    return Plugin_Handled;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (client <= 0 || !IsClientInGame(client))
        return;

    float savedYawSpeed = GetClientYawSpeed(client);
    if (savedYawSpeed != -1.0)
        SetClientYawSpeed(client, savedYawSpeed);
}

public Action OnRunCommand(int client, int& iCommand, int& iArgs)
{
    if (!IsClientInGame(client) || GetClientTeam(client) == CS_TEAM_SPECTATOR)
        return Plugin_Continue;

    float newYawSpeed = GetClientYawSpeed(client);

    if (newYawSpeed >= 0.0)
    {
        float fMouseX = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[0]");
        float fMouseY = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");
        fMouseY += newYawSpeed * fMouseX;
        SetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]", fMouseY);
    }

    return Plugin_Continue;
}

public float GetClientYawSpeed(int client)
{
    if (client <= 0 || client > MaxClients)
        return -1.0;

    return view_as<float>(g_PlayerYawSpeeds.Get(client - 1));
}

public void SetClientYawSpeed(int client, float newYawSpeed)
{
    if (client <= 0 || client > MaxClients)
        return;

    g_PlayerYawSpeeds.Set(client - 1, view_as<int>(newYawSpeed));
}
