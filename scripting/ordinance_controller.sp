#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1
#define MAX_INPUT_LEN 256
#define PLAYER_PAWN_FILE "player_pawn.txt"

ConVar g_ordinance_enabled;
char g_mapname[128];
public Plugin myinfo =
{
	name = "ordinance_controller",
	author = "TheRedEnemy",
	description = "",
	version = "1.0.1",
	url = "https://github.com/theredenemy/ordinance_controller"
};

void makeConfig()
{
	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", PLAYER_PAWN_FILE);
	if (!FileExists(path))
	{
		PrintToServer(path);
		KeyValues kv = new KeyValues("Player_Pawn");
		kv.SetString("playername", "SERVICE MANAGER");
		kv.SetString("date", "DECEMBER 31TH 2099");
		kv.Rewind();
		kv.ExportToFile(path);
		delete kv;
	}
}
public void OnMapStart()
{
	g_mapname = "\0";
	int ordinance_enabled = GetConVarInt(g_ordinance_enabled);
	GetCurrentMap(g_mapname, sizeof(g_mapname));
	if (StrEqual(g_mapname, "ordinance"))
	{
		if (ordinance_enabled == 1) {SendInput("BEGIN");}
	}
	
}

public void OnPluginStart()
{
	makeConfig();
	g_ordinance_enabled = CreateConVar("ordinance_enabled", "0");
	RegServerCmd("ord_input", ord_input_command);
	RegServerCmd("ord_render", ord_render_command);
	PrintToServer("ordinance_controller Has Loaded");
}


public void SendInput(const char[] input)
{
	char path[PLATFORM_MAX_PATH];
	char pawn_name[MAX_NAME_LENGTH];
	BuildPath(Path_SM, path, sizeof(path), "configs/%s", PLAYER_PAWN_FILE);
	KeyValues kv = new KeyValues("Player_Pawn");
	if (!kv.ImportFromFile(path))
	{
		PrintToServer("NO FILE");
		delete kv;
		return;
	}

	if (kv.JumpToKey("playername", false))
	{
		kv.GetString(NULL_STRING, pawn_name, sizeof(pawn_name));
		delete kv;
	}

	PrintToServer("input : %s pawn_name : %s", input, pawn_name);
}

public Action ord_input_command(int args)
{
	char arg[MAX_INPUT_LEN];
    char full[256];
	char map[256];
	int ordinance_enabled = GetConVarInt(g_ordinance_enabled);
	if (args > 1)
	{
		PrintToServer("ONLY ONE INPUT AT A TIME");
		return Plugin_Handled;
	}
	else if(args < 1)
	{
		PrintToServer("[SM] Usage: ord_input <input>");
		return Plugin_Handled;
	}
	if (ordinance_enabled != 1)
	{
		if (IsMapValid("ord_end"))
		{
			ForceChangeLevel("ord_end", "NO INPUT");
			return Plugin_Handled;
		}
		else
		{
			ForceChangeLevel("cp_dustbowl", "NO INPUT");
			return Plugin_Handled;
		}
	}

    GetCmdArgString(full, sizeof(full));
	
	GetCmdArg(1, arg, sizeof(arg));
	Format(map, sizeof(map), "ord_%sfunc", arg);
	PrintToServer(map);
	if (IsMapValid(map))
	{
		SendInput(arg);
		ForceChangeLevel(map, "INPUT MADE");
	}
	else
	{
		ForceChangeLevel("cp_dustbowl", "INVAILD INPUT");
		return Plugin_Handled;
	}
	
	
	return Plugin_Handled;

}

public Action ord_render_command(int args)
{
	int ordinance_enabled = GetConVarInt(g_ordinance_enabled);
	if (IsMapValid("ord_ren"))
	{
		if (ordinance_enabled == 1) {SendInput("ren");}
		ForceChangeLevel("ord_ren", "RENDER");
		return Plugin_Handled;
	}
	else
	{
		ForceChangeLevel("cp_dustbowl", "NO MAP");
		return Plugin_Handled;
	}
}