#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

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

float g_PlayerPrevViewAngle[3];
const int MAX_TICKS = 5;
float g_LastFiveViewAngleDiffs[MAX_TICKS];
int g_NumStoredTicks = 0;

float GetClientVelocity(int client)
{
    float velocity[3];

    velocity[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
    velocity[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");

    return GetVectorLength(velocity);
}

void CalculateViewAngleDiff(float currentViewAngleDiff)
{
    if (g_NumStoredTicks < MAX_TICKS)
    {
        g_LastFiveViewAngleDiffs[g_NumStoredTicks] = currentViewAngleDiff;
        g_NumStoredTicks++;
    }
    else
    {
        for (int i = 1; i < MAX_TICKS; i++)
        {
            g_LastFiveViewAngleDiffs[i - 1] = g_LastFiveViewAngleDiffs[i];
        }
        g_LastFiveViewAngleDiffs[MAX_TICKS - 1] = currentViewAngleDiff;
    }
}

float CalculateTotalViewAngleDiff()
{
    float totalDiff = 0.0;
    for (int i = 0; i < g_NumStoredTicks; i++)
    {
        totalDiff += g_LastFiveViewAngleDiffs[i];
    }
    return totalDiff;
}

const float VIEW_ANGLE_THRESHOLD = 0.1; // Adjust this threshold value as needed

float NormalizeAngle(float angle)
{
    while (angle > 180.0)
    {
        angle -= 360.0;
    }
    while (angle < -180.0)
    {
        angle += 360.0;
    }
    return angle;
}

float CustomFloatAbs(float num)
{
    return num >= 0 ? num : -num;
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

    float viewAngleDiff[3];
    viewAngleDiff[0] = angles[0] - g_PlayerPrevViewAngle[0];
    viewAngleDiff[1] = angles[1] - g_PlayerPrevViewAngle[1];

    viewAngleDiff[1] = NormalizeAngle(viewAngleDiff[1]);

    g_PlayerPrevViewAngle[0] = angles[0];
    g_PlayerPrevViewAngle[1] = angles[1];

    CalculateViewAngleDiff(viewAngleDiff[1]);

    if (g_NumStoredTicks >= MAX_TICKS)
    {
        float totalViewAngleDiff = CalculateTotalViewAngleDiff();

        // Determine the more common result (left or right)

        if (CustomFloatAbs(totalViewAngleDiff) > VIEW_ANGLE_THRESHOLD)
        {
            if (totalViewAngleDiff > 0)
            {
                PrintToChat(client, "[Turn Direction]: You are turning left");
            }
            else
            {
                PrintToChat(client, "[Turn Direction]: You are turning right");
            }
        }
        else
        {
            PrintToChat(client, "[Turn Direction]: You are turning straight");
        }
    }

    return Plugin_Continue;
}
