#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

float g_playerYawspeed[MAXPLAYERS + 1];
Handle g_turnTimer[MAXPLAYERS + 1];
float g_timerInterval;

public void OnPluginStart() {
    g_timerInterval = GetTickInterval();

    RegConsoleCmd("sm_setyawspeed", Command_yawspeed);
    RegConsoleCmd("+sm_turnleft", Command_start_turnleft);
    RegConsoleCmd("-sm_turnleft", Command_stop_turnleft);
    RegConsoleCmd("+sm_turnright", Command_start_turnright);
    RegConsoleCmd("-sm_turnright", Command_stop_turnright);

    for (int i = 1; i <= MAXPLAYERS; ++i) {
        g_playerYawspeed[i] = 140.0; // Default yawspeed value
    }
}

public Action Command_yawspeed(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (args > 0) {
        float newYawspeed = view_as<float>(GetCmdArgInt(1));
        g_playerYawspeed[client] = newYawspeed;
        PrintToChat(client, "Your yawspeed is now set to %.0f", newYawspeed);
    } else {
        PrintToChat(client, "Your current yawspeed is %.0f", g_playerYawspeed[client]);
    }

    return Plugin_Handled;
}

public Action Command_start_turnleft(int client, int args) {
    if (!IsClientConnected(client) || !IsClientInGame(client)) {
        return Plugin_Handled;
    }

    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
    }

    g_turnTimer[client] = CreateTimer(g_timerInterval, Timer_turn, view_as<int>(client) | (1 << 31), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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

    g_turnTimer[client] = CreateTimer(g_timerInterval, Timer_turn, view_as<int>(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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

    float yawspeed = g_playerYawspeed[client] * (isLeft ? -1.0 : 1.0);

    turn(client, yawspeed);
    return Plugin_Continue;
}

void turn(int client, float degrees) {
    float origin[3], angles[3], velocity[3];

    GetClientEyeAngles(client, angles);
    GetClientAbsOrigin(client, origin);
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);

    angles[1] += degrees;
    TeleportEntity(client, origin, angles, velocity); //theres gotta be a better way than this
}

// void turn(int client, float degrees) {
//     float angles[3];

//     GetClientEyeAngles(client, angles);
//     angles[1] += degrees;
 //    SetEntPropVector(client, Prop_Send, "m_angEyeAngles", angles);
//}


public void OnClientDisconnect(int client) {
    if (g_turnTimer[client] != null) {
        KillTimer(g_turnTimer[client]);
        g_turnTimer[client] = null;
    }
}
