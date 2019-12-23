#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <cstrike>
#include <sdktools>

ConVar minPlayers;
ConVar mapToOpen;

int numPrinted = 0;
char mapOpen[128];

public Plugin myinfo =  
{
	name 	= "[CSGO] Otomatik Harita Değiştirici",
	author 	= "ImPossibLe` & Fix: @KingHenny!",
	version = "1.0.2"
}

public void OnPluginStart()
{
	HookEvent("round_end", roundEnd);
	
	minPlayers = CreateConVar("sm_oto-harita_oyuncu", "4", "Harita değiştirmek için sunucuda bulunması gereken oyuncu sayısı");
	mapToOpen = CreateConVar("sm_oto-harita_haritaIsmi", "de_dust2", "Açılacak harita ismi");
	
	AutoExecConfig(true, "henny_oto-harita", "SourceTURK");
}

public Action roundEnd(Handle event, char[] name, bool dontBroadcast)
{
	if (GameRules_GetProp("m_bWarmupPeriod") != 0)
	{
		return Plugin_Handled;
	}
	
	int playerNumber = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (IsClientConnected(i) && GetClientTeam(i) > 1)
			{
				playerNumber++;
			}
		}
	}
	
	GetConVarString(mapToOpen, mapOpen, sizeof(mapOpen));
	
	char mapName[64];
	GetCurrentMap(mapName, sizeof(mapName));
	if (!StrEqual(mapName, mapOpen, false))
	{
		if (playerNumber < GetConVarInt(minPlayers))
		{
			numPrinted = 6;
			CreateTimer(1.0, countdown, _, TIMER_REPEAT);
		}
	}
	
	return Plugin_Continue;
}

public Action countdown(Handle timer)
{
	numPrinted--;

	if (numPrinted > 0)
	{
		if (IsMapValid(mapOpen))
		{
			PrintToChatAll("[\x05SourceTurk\x01] Sunucuda az kişi olduğu için, mevcut harita \x04%i \x01ile değiştiriliyor...", GetConVarInt(mapToOpen));
			
			char command[256];
			Format(command, sizeof(command), "sm_map %i", GetConVarInt(mapToOpen));
			ServerCommand(command);
		}
		else
		{
			PrintToChatAll("[\x05SourceTurk\x01] Sunucuda harita bulunamadığı için, otomatik olarak \x04de_dust2 \x01açılıyor...");
			ServerCommand("sm_map de_dust2");
		}
		
		return Plugin_Stop;
	}
 
	PrintToChatAll("[\x05SourceTurk\x01] Sunucuda az kişi olduğu için \x10%i saniye \x01sonra harita değiştirilecektir... (Açılacak Harita: %i)", numPrinted, GetConVarInt(mapToOpen));
	return Plugin_Continue;
}
