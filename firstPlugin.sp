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
    url = "https://github.com/jackthatch/css-ssj"
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

float GetClientAngles(int client)
{
    float V_angles[3];
    int res;

	//normalize these angle from 0-360deg rather than 0-> 180 -> -180 -> 0
	
	//Getting same values here need to sleep for 1 or 2 ticks between each line
    V_angles[0] = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");
    V_angles[1] = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");
    V_angles[2] = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");

    if (V_angles[0] < V_angles[1] && V_angles[1] < V_angles[2])    // Turning right
    {
        res = 0;
    }
    else if (V_angles[0] > V_angles[1] && V_angles[1] > V_angles[2])   // Turning left
    {
        res = 1;
    }
    else
    {
        res = 2;   // Not Turning
    }

	 PrintToChat(client, "[JThatch Shit Strafer]: 0: %.2f, 1: %.2f, 2: %.2f", V_angles[0], V_angles[1], V_angles[2]);
    return res;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    bool isOnGround = (GetEntityFlags(client) & FL_ONGROUND) != 0;
    bool isJumping = (buttons & IN_JUMP) != 0;

    if (isJumping)
    {
        int direction = GetClientAngles(client);
        if (direction == 0)
        {
            PrintToChat(client, "[JThatch Shit Strafer]: Turning right");
        }
        else if (direction == 1)   // Use "else if" for the second condition
        {
            PrintToChat(client, "[JThatch Shit Strafer]: Turning left");
        }
        else
        {
            PrintToChat(client, "[JThatch Shit Strafer]: Not Turning !");
        }
    }

    if (isOnGround && isJumping)
    {
        float speed = GetClientVelocity(client);
        PrintToChat(client, "[Speed]: You landed on the ground with a speed of %.2f", speed);

        float VA = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");
        PrintToChat(client, "[Speed]: Current angle:  %.2f", VA);
    }

    return Plugin_Continue;
}
