#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#include <sourcemod>
#include <sdktools>
#include <cstrike>

EngineVersion g_Game;

public Plugin myinfo =
{
    name = "BhopSpeedTracker",
    author = "Jack Thatcher",
    description = "",
    version = "0.1",
    url = "https://github.com/jackthatch/source-ssj"
};

public void OnPluginStart()
{
    g_Game = GetEngineVersion();
    if (g_Game != Engine_CSGO && g_Game != Engine_CSS)
    {
        SetFailState("This plugin is for CSGO/CSS only.");
    }
}

float GetClientVelocity(int client)
{
    float velocity[3];

    velocity[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
    velocity[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");

    return GetVectorLength(velocity);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    bool isOnGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;
    bool isJumping = (buttons & IN_JUMP) != 0;

    if (isOnGround && isJumping)
    {
        float speed = GetClientVelocity(client);
        PrintToChat(client, "[Speed]: You landed on the ground with a speed of %.2f", speed);
    }

    return Plugin_Continue;
}


