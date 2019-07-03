#include <sourcemod>
#include <sdktools>
#include <sdktools_hooks>
#include <tf2>
#include <tf2_stocks>
public Plugin:myinfo = 
{
	name = "Perks&Abilities for everyone",
	author = "Dllsearch",
	description = "<- Description ->",
	version = "0.0.1",
	url = "<- URL ->"
}

enum perks {
	civilian,
	rager,
	runner,
	spamer,
	tank,
	snake,
	agent
};

int pnd_AbilityPoints[MAXPLAYERS + 1] = {0, ...};
perks pnd_Abilities[MAXPLAYERS + 1] = {0, ...};

ConVar pnd_abl_chrg_k;
ConVar pnd_abl_chrg_t;
// ConVar pnd_abl_num;

public void OnPluginStart()
{
	HookEvent("player_hurt", charger);
	pnd_abl_chrg_k = CreateConVar("pnd_abl_chrg_k", "5", "Coefficient of taking ability points");
	pnd_abl_chrg_t = CreateConVar("pnd_abl_chrg_t", "1", "Amount of ability points per second");
	// pnd_abl_num = CreateConVar("pnd_abl_num", "0", "Description");
	
	RegConsoleCmd("pna_ability_use", useAbility);
	
	//RegConsoleCmd("pna_ability_new", setAbility);
	
	RegConsoleCmd("perks", perkDeckPanel);
	
}

public void OnClientPutInServer(int client)
{
	pnd_AbilityPoints[client] = 0;
	pnd_Abilities[client] = 0;
	perkDeckPanel(client, 0);
}

public OnClientConnected(int client)
{
	
}
 
 /// --- /// --- /// --- ///
 
public int perkDeckPanelHandler(Menu menu, MenuAction action, int client, int ablt)
{
	if (action == MenuAction_Select)
	{
		PrintToConsole(client, "You selected perk # %d", ablt);
		pnd_Abilities[client] = ablt;
	}
	else if (action == MenuAction_Cancel)
	{
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", client, ablt);
	}
}
 
public Action perkDeckPanel(int client, int args)
{
	Panel panel = new Panel();
	panel.SetTitle("Choose your deck:");
	panel.DrawItem("rager");
	panel.DrawItem("runner");
	panel.DrawItem("spamer");
	panel.DrawItem("tank");
	panel.DrawItem("snake");
	panel.DrawItem("agent");
 
	panel.Send(client, perkDeckPanelHandler, 20);
 
	delete panel;
 
	return Plugin_Handled;
}

/// --- /// --- /// --- ///

public Action useAbility(int client, int args)
{
	char arg[128];
	char full[256];
 
	GetCmdArgString(full, sizeof(full));
 
	if (client)
	{
		PrintToServer("Command pna_ability_use from client %d", client);
	} else {
		PrintToServer("Command pna_ability_use from server");
	}
 
	PrintToServer("Argument string: %s", full);
	PrintToServer("Argument count: %d", args);
	for (int i=1; i<=args; i++)
	{
		GetCmdArg(i, arg, sizeof(arg));
		PrintToServer("Argument %d: %s", i, arg);
	}
	
	if ( pnd_AbilityPoints[client] == 100 )
	{
		pnd_AbilityPoints[client] = 0;
		if (pnd_Abilities[client] == 1) frager(client);
		else if (pnd_Abilities[client] == 2) frunner(client);
		else if (pnd_Abilities[client] == 3) fspamer(client);
		else if (pnd_Abilities[client] == 4) ftank(client);
		else if (pnd_Abilities[client] == 5) fsnake(client);
		PrintToChat(client, "ABILITY USED"); 
	}
	else 
	{
		PrintToChat(client, "%d%% charged", pnd_AbilityPoints[client]);
	}
	
	return Plugin_Handled;
} 

public void frager(int client)
{
	int conds[4] = {19, 26, 29, 60};
	pna_addcond (conds, client, 17.50, 4);
	pnd_AbilityPoints[client] = 53;
}

public void frunner(int client)
{
	int conds[3] = {26, 42, 72};
	pna_addcond (conds, client, 7.50,3);
	pnd_AbilityPoints[client] = 88;
}

public void fspamer(int client)
{
	int conds[3] = {16, 72, 91};
	pna_addcond (conds, client, 15.00,3);
	pnd_AbilityPoints[client] = 35;
}

public void ftank(int client)
{
	int conds[7] = {26, 42, 61, 62, 63, 73, 93};
	pna_addcond (conds, client, 30.00, 7);
	pnd_AbilityPoints[client] = 0;
}

public void fsnake(int client)
{
	int conds[4] = {19, 26, 29, 60};
	pna_addcond (conds, client, 8.00,4);
	pnd_AbilityPoints[client] = 75;
}

public charger(Event hEvent, const char[] name, bool dontBroadcast)
{
	//int client = GetClientOfUserId(hEvent.GetInt("userid"));
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));
	damage_charger(attacker, pnd_abl_chrg_k.IntValue);
}

public void damage_charger(int client, int points)
{
	for (int x = 0; (x < points) && (pnd_AbilityPoints[client] != 100); x++)
	{
		pnd_AbilityPoints[client] += 1;
	}
	if ((client != 0) && ((pnd_AbilityPoints[client] == 50) || (pnd_AbilityPoints[client] == 70) || (pnd_AbilityPoints[client] == 90))) PrintToChat(client, "#%d ability %i %% charged",pnd_Abilities, pnd_AbilityPoints[client]);
	if ((pnd_AbilityPoints[client] == 100) && (client != 0)) PrintToChat(client, "ABILITY READY !!!");
}

public void time_charger() //TODO
{
	for (int i = 0; i <= MAXPLAYERS ; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && (pnd_AbilityPoints[i] != 100)) pnd_AbilityPoints[i] += pnd_abl_chrg_t.IntValue;
	}
}


TFCond tfca[128] = {
	TFCond_Slowed,
	TFCond_Zoomed,
	TFCond_Disguising,
	TFCond_Disguised,
	TFCond_Cloaked,
	TFCond_Ubercharged,
	TFCond_TeleportedGlow,
	TFCond_Taunting,
	TFCond_UberchargeFading,
	//TFCond_Unknown1,
	TFCond_CloakFlicker,
	TFCond_Teleporting,
	TFCond_Kritzkrieged,
	//TFCond_Unknown2,
	TFCond_TmpDamageBonus,
	TFCond_DeadRingered,
	TFCond_Bonked,
	TFCond_Dazed,
	TFCond_Buffed,
	TFCond_Charging,
	TFCond_DemoBuff,
	TFCond_CritCola,
	TFCond_InHealRadius,
	TFCond_Healing,
	TFCond_OnFire,
	TFCond_Overhealed,
	TFCond_Jarated,
	TFCond_Bleeding,
	TFCond_DefenseBuffed,
	TFCond_Milked,
	TFCond_MegaHeal,
	TFCond_RegenBuffed,
	TFCond_MarkedForDeath,
	TFCond_NoHealingDamageBuff,
	TFCond_SpeedBuffAlly,
	TFCond_HalloweenCritCandy,
	TFCond_CritCanteen,
	TFCond_CritDemoCharge,
	TFCond_CritHype,
	TFCond_CritOnFirstBlood,
	TFCond_CritOnWin,
	TFCond_CritOnFlagCapture,
	TFCond_CritOnKill,
	TFCond_RestrictToMelee,
	TFCond_DefenseBuffNoCritBlock,
	TFCond_Reprogrammed,
	TFCond_CritMmmph,
	TFCond_DefenseBuffMmmph,
	TFCond_FocusBuff,
	TFCond_DisguiseRemoved,
	TFCond_MarkedForDeathSilent,
	TFCond_DisguisedAsDispenser,
	TFCond_Sapped,
	TFCond_UberchargedHidden,
	TFCond_UberchargedCanteen,
	TFCond_HalloweenBombHead,
	TFCond_HalloweenThriller,
	TFCond_RadiusHealOnDamage,
	TFCond_CritOnDamage,
	TFCond_UberchargedOnTakeDamage,
	TFCond_UberBulletResist,
	TFCond_UberBlastResist,
	TFCond_UberFireResist,
	TFCond_SmallBulletResist,
	TFCond_SmallBlastResist,
	TFCond_SmallFireResist,
	TFCond_Stealthed,
	TFCond_MedigunDebuff,
	TFCond_StealthedUserBuffFade,
	TFCond_BulletImmune,
	TFCond_BlastImmune,
	TFCond_FireImmune,
	TFCond_PreventDeath,
	TFCond_MVMBotRadiowave,
	TFCond_HalloweenSpeedBoost,
	TFCond_HalloweenQuickHeal,
	TFCond_HalloweenGiant,
	TFCond_HalloweenTiny,
	TFCond_HalloweenInHell,
	TFCond_HalloweenGhostMode,
	TFCond_MiniCritOnKill,
	TFCond_ObscuredSmoke, //TFCond_DodgeChance,
	TFCond_Parachute,
	TFCond_BlastJumping,
	TFCond_HalloweenKart,
	TFCond_HalloweenKartDash,
	TFCond_BalloonHead,
	TFCond_MeleeOnly,
	TFCond_SwimmingCurse,
	TFCond_FreezeInput, //TFCond_HalloweenKartNoTurn,
	TFCond_HalloweenKartCage,
	TFCond_HasRune,
	TFCond_RuneStrength,
	TFCond_RuneHaste,
	TFCond_RuneRegen,
	TFCond_RuneResist,
	TFCond_RuneVampire,
	TFCond_RuneWarlock,
	TFCond_RunePrecision,
	TFCond_RuneAgility,
	TFCond_GrapplingHook,
	TFCond_GrapplingHookSafeFall,
	TFCond_GrapplingHookLatched,
	TFCond_GrapplingHookBleeding,
	TFCond_AfterburnImmune,
	TFCond_RuneKnockout,
	TFCond_RuneImbalance,
	TFCond_CritRuneTemp,
	TFCond_PasstimeInterception,
	TFCond_SwimmingNoEffects,
	TFCond_EyeaductUnderworld,
	TFCond_KingRune,
	TFCond_PlagueRune,
	TFCond_SupernovaRune,
	TFCond_Plague,
	TFCond_KingAura,
	TFCond_SpawnOutline,
	TFCond_KnockedIntoAir,
	TFCond_CompetitiveWinner,
	TFCond_CompetitiveLoser,
	//TFCond_NoTaunting,
	//TFCond_NoTaunting_DEPRECATED,
	TFCond_HealingDebuff,
	TFCond_PasstimePenaltyDebuff,
	TFCond_GrappledToPlayer,
	TFCond_GrappledByPlayer,
	TFCond_ParachuteDeployed,
	TFCond_Gas,
	TFCond_BurningPyro,
	TFCond_RocketPack,
	TFCond_LostFooting,
	TFCond_AirCurrent
}

public pna_addcond (int[] conds, int client, float time, int count)
{
	int c = 0;
	while ((conds[c] != 300) && (c <= count)/*&& (conds[c] != null)*/)
	{
		TF2_AddCondition(client, tfca[conds[c]/*c*/], time, 0);
		//TF2_AddCondition(client, tfca[/*conds[c]*/c], time, client);
		c++;
	}
}

public pna_removecond (int[] conds, int client)
{
	int c = 0;
	while ((conds[c] != 300) /* && (conds[c] != null) */)
	{
		TF2_RemoveCondition(client, tfca[conds[c]]);
	}
}
