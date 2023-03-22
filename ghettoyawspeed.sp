#include <sourcemod>
#include <sdktools>

ConVar g_yawspeedCvar;
Handle g_turnTimer[MAXPLAYERS + 1];

public void OnPluginStart() {
    g_yawspeedCvar = CreateConVar("sm_yawspeed", "140", "Sets the yawspeed for each player individually.", FCVAR_NOTIFY);

    RegConsoleCmd("sm_yawspeed", Command_yawspeed);
    RegConsoleCmd("+sm_turnleft", Command_start_turnleft);
    RegConsoleCmd("-sm_turnleft", Command_stop_turnleft);
    RegConsoleCmd("+sm_turnright", Command_start_turnright);
    RegConsoleCmd("-sm_turnright", Command_stop_turnright);
}

public Action Command_yawspeed(int client, int args) {
    if (args > 0) {
        float newYawspeed = view_as<float>(GetCmdArgInt(1));
        SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", newYawspeed);
        PrintToChat(client, "Your yawspeed is now set to %.0f", newYawspeed);
    } else {
        float yawspeed = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
        PrintToChat(client, "Your current yawspeed is %.0f", yawspeed);
    }

    return Plugin_Handled;
}

public Action Command_start_turnleft(int client, int args) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
    }

    float yawspeed = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
    g_turnTimer[client] = CreateTimer(0.01, Timer_turn, view_as<int>(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Command_stop_turnleft(int client, int args) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }

    return Plugin_Handled;
}

public Action Command_start_turnright(int client, int args) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
    }

    float yawspeed = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
    g_turnTimer[client] = CreateTimer(0.01, Timer_turn, view_as<int>(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    return Plugin_Handled;
}

public Action Command_stop_turnright(int client, int args) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }

    return Plugin_Handled;
}

public Action Timer_turn(Handle timer, any client) {
    if (client <= 0) {
        return Plugin_Stop;
    }

    float degrees = GetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue");
    turn(client, degrees);
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