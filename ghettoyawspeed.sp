#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

ConVar g_yawspeedCvar;
Handle g_turnTimer[MAXPLAYERS + 1];

public void OnPluginStart() {
    g_yawspeedCvar = CreateConVar("sm_yawspeed", "140", "Sets the yawspeed for each player individually.", FCVAR_NOTIFY | FCVAR_REPLICATED);

    RegConsoleCmd("+sm_turnleft", Command_start_turnleft);
    RegConsoleCmd("-sm_turnleft", Command_stop_turnleft);
    RegConsoleCmd("+sm_turnright", Command_start_turnright);
    RegConsoleCmd("-sm_turnright", Command_stop_turnright);
}

public Action Command_start_turnleft(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
    }

    g_turnTimer[client] = CreateTimer(0.015, Timer_turn, view_as<int>(client) | (1 << 31), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Command_stop_turnleft(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }

    return Plugin_Handled;
}

public Action Command_start_turnright(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
    }

    g_turnTimer[client] = CreateTimer(0.015, Timer_turn, view_as<int>(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Command_stop_turnright(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }

    return Plugin_Handled;
}

public Action Timer_turn(Handle timer, any data) {
    int client = data & ~(1 << 31);
    bool isLeft = (data >> 31) & 1;

    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Stop;
    }

    float yawspeed = GetConVarFloat(g_yawspeedCvar) * (isLeft ? -1.0 : 1.0);

    turn(client, yawspeed);
    return Plugin_Continue;
}

void turn(int client, float degrees) {
    float origin[3], angles[3], velocity[3];

    GetClientEyeAngles(client, angles);
    GetClientAbsOrigin(client, origin);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

    angles[1] += degrees;
    TeleportEntity(client, origin, angles, velocity);
}

public void OnClientDisconnect(int client) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }
}
