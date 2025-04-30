// Pibble v2 by kin
//
// credits:
// -ficool2 for screenspade shader sdk
// -
// NetProps method bindings (credit: ficool2)
// "around 20% faster"

if(startswith(GetMapName(), "pib_mesa")) IncludeScript("pib_mesa.nut")

::GetPropArraySize <- ::NetProps.GetPropArraySize.bindenv(::NetProps);
::GetPropEntity <- ::NetProps.GetPropEntity.bindenv(::NetProps);
::GetPropEntityArray <- ::NetProps.GetPropEntityArray.bindenv(::NetProps);
::GetPropBool <- ::NetProps.GetPropBool.bindenv(::NetProps);
::GetPropBoolArray <- ::NetProps.GetPropBoolArray.bindenv(::NetProps);
::GetPropFloat <- ::NetProps.GetPropFloat.bindenv(::NetProps);
::GetPropFloatArray <- ::NetProps.GetPropFloatArray.bindenv(::NetProps);
::GetPropInfo <- ::NetProps.GetPropInfo.bindenv(::NetProps);
::GetPropInt <- ::NetProps.GetPropInt.bindenv(::NetProps);
::GetPropIntArray <- ::NetProps.GetPropIntArray.bindenv(::NetProps);
::GetPropString <- ::NetProps.GetPropString.bindenv(::NetProps);
::GetPropStringArray <- ::NetProps.GetPropStringArray.bindenv(::NetProps);
::GetPropType <- ::NetProps.GetPropType.bindenv(::NetProps);
::GetPropVector <- ::NetProps.GetPropVector.bindenv(::NetProps);
::GetPropVectorArray <- ::NetProps.GetPropVectorArray.bindenv(::NetProps);
::GetTable <- ::NetProps.GetTable.bindenv(::NetProps);
::HasProp <- ::NetProps.HasProp.bindenv(::NetProps);
::SetPropBool <- ::NetProps.SetPropBool.bindenv(::NetProps);
::SetPropBoolArray <- ::NetProps.SetPropBoolArray.bindenv(::NetProps);
::SetPropEntity <- ::NetProps.SetPropEntity.bindenv(::NetProps);
::SetPropEntityArray <- ::NetProps.SetPropEntityArray.bindenv(::NetProps);
::SetPropFloat <- ::NetProps.SetPropFloat.bindenv(::NetProps);
::SetPropFloatArray <- ::NetProps.SetPropFloatArray.bindenv(::NetProps);
::SetPropInt <- ::NetProps.SetPropInt.bindenv(::NetProps);
::SetPropIntArray <- ::NetProps.SetPropIntArray.bindenv(::NetProps);
::SetPropString <- ::NetProps.SetPropString.bindenv(::NetProps);
::SetPropStringArray <- ::NetProps.SetPropStringArray.bindenv(::NetProps);
::SetPropVector <- ::NetProps.SetPropVector.bindenv(::NetProps);
::SetPropVectorArray <- ::NetProps.SetPropVectorArray.bindenv(::NetProps);

////////////
// Constants
////////////

// Team IDs
::RED_TEAM <- 2
::BLU_TEAM <- 3
::NEUTRAL <- 0 //ball

// Point values
::POINTS_PASS <- 100
::POINTS_TURNOVER <- 200
::POINTS_STEAL <- 500
::POINTS_EXTENDER <- 420
::POINTS_HANDOFF <- 350

// Point multipliers
::POINTS_EXTENDER_VELOCITY_BASE <- 0.8
::POINTS_EXTENDER_VELOCITY_SCALE <- 1.25
::POINTS_EXTENDER_VELOCITY_CAP <- 1500
::POINTS_INTERCEPT_VELOCITY_BASE <- 0.5
::POINTS_INTERCEPT_VELOCITY_SCALE <- 1.5
::POINTS_HANDOFF_HEIGHT_BASE <- 1.0
::POINTS_HANDOFF_HEIGHT_SCALE <- 1.5
::POINTS_HANDOFF_HEIGHT_CAP <- 1500
::POINTS_CHAIN_MULTIPLIER <- 1.15

// Constants for ClientPrint
::HUD_PRINTNOTIFY <- 1    // Chat area
::HUD_PRINTCONSOLE <- 2   // Console
::HUD_PRINTTALK <- 3      // Chat area
::HUD_PRINTCENTER <- 4    // Center of screen

//Max weapons in player's inventory for iteration
::MAX_WEAPONS <- 8

::DMGTYPE_ROCKET <- 2359360
::DMGTYPE_MELEE <- 134221952
::DMG_DIRECT <- 90


// Team colors for text
::g_teamColor <- {
    [2] = "222 59 18", // RED_TEAM
    [3] = "22 107 245" // BLU_TEAM
}

::g_teamChatColor <- {
    [2] = "\x07DE3B12", // RED_TEAM (222 59 18)
    [3] = "\x07166BF5", // BLU_TEAM (22 107 245)
    [0] = "\x07FFFFFF"  // Neutral (255 255 255)
}

////////////////////
// Global variables
////////////////////

//Text objects
::g_gt <- null


// Entity detection
::g_ballEntity <- null // passtime_ball
::g_hudEntity <- null // pd hud logic
::g_goalEntities <- {
    [2] = null, // RED_TEAM
    [3] = null // BLU_TEAM
} // func_passtime_goal entities
::g_timerEntity <- null // game_round_timer
::g_scriptEntity <- null // logic_script
::g_zonesFound <- false
::g_biEntity <- null // ball indicator brush
::g_matEntity <- null // material control

// Player states
::g_throwVelocity <- null // Player velocity at time of last throw
::g_rocketJumpState <- {} // Rocket jump state per player
::g_validExtenderSplash <- {} // Valid extender splash per player
::g_validExtenderThrow <- {} // Valid extender throw per player
::g_validExtenderAttempt <- {} // Valid extender attempt per player
::g_validZoneExtenderAttempt <- {

}
::g_validInstadetExtenderAttempt <- {}
::g_awardInstadetExtender <- {}// Valid extender attempt in special zones

// Ball detection states
::g_lastThrowTime <- 0 // Time of last ball_free event
::g_lastBallDamager <- null // Last player to damage the ball
::g_ballState <- {
    "state" : "neutral",
    "lastState" : "neutral",
    "time" : 0,
    "velocity" : {},
    "position" : {},
    "lastCarrier" : null,
    "currentCarrier" : null,
    "carrierTeam" : null,
    "lastTeam" : null,
}

::g_specFlag <- 0 // flag for special move text being colored in chat

::g_zoneEntities <- {} // track entities in each special zone
::g_requiredTypes <- ["player", "passtime_ball"]

::g_validInstadetSplash <- {} // Valid instadet splash per player


::g_ballFanned <- false
::g_splashTime <- {} // Time of last splash per player
::g_instadet <- {}
::g_overtime <- false
::g_last5Sec <- false
// Scoring variables
::g_teamScores <- {
    [2] = 0, // RED_TEAM
    [3] = 0 // BLU_TEAM
}
::g_pendingPoints <- {
    [2] = 0, // RED_TEAM
    [3] = 0 // BLU_TEAM
}
::g_previousPendingPoints <- {
    [2] = 0, // RED_TEAM
    [3] = 0 // BLU_TEAM
}
::g_extenderChainCount <- {
    [2] = 0, // RED_TEAM
    [3] = 0 // BLU_TEAM
}
::g_teamManagers <- {
    [2] = null, // RED_TEAM
    [3] = null // BLU_TEAM
}

// Player settings globals
if(!("g_playerFOV" in getroottable()))
{
::g_playerFOV <- {}
printl("No g_playerFOV table found. Initializing.")
}
if(!("g_centeredProjectiles" in getroottable()))
{
::g_centeredProjectiles <- {}
printl("No g_centeredProjectiles table found. Initializing.")
}

///////////////
// FUNCTIONS
///////////////
::DebugPrint <- function(msg)
{
    printl("[PibbleDebug] " + msg);
}

::CollectEventsInScope <- function(events)
{
    local events_id = UniqueString()
    getroottable()[events_id] <- events
    local events_table = getroottable()[events_id]
    foreach (name, callback in events) events_table[name] = callback.bindenv(this)
    local cleanup_user_func, cleanup_event = "OnGameEvent_scorestats_accumulated_update"
    if (cleanup_event in events) cleanup_user_func = events[cleanup_event].bindenv(this)
    events_table[cleanup_event] <- function(params){
        if (cleanup_user_func) cleanup_user_func(params)
        delete getroottable()[events_id]
    }
    __CollectGameEventCallbacks(events_table)
}

CollectEventsInScope({
    OnGameEvent_teamplay_round_start = function(params)
    {
        local player = null
        while (player = Entities.FindByClassname(player, "player")){
        local playerIndex = player.entindex()
        DebugPrint("Player " + GetPlayerName(player) + " index: " + playerIndex)

        DebugPrint("Player's handle 'player': " + player)
            if (player in g_playerFOV){
                SetPlayerFOV(player, g_playerFOV[player])
                DebugPrint("Restored FOV " + g_playerFOV[player] + " for player " + GetPlayerName(player))
            }
        }
        //local bluGoal = Entities.FindByName(null, "blue_goal")
        //local redGoal = Entities.FindByName(null, "red_goal")

        InitializeConvars()

        //EntFireByHandle(bluGoal, "AddOutput", "points 0", 0, null, null)
        //EntFireByHandle(redGoal, "AddOutput", "points 0", 0, null, null)


    }

    OnGameEvent_player_spawn = function(params)
    {
        if (!("userid" in params))
        return;

    try
    {
        local player = GetPlayerFromUserID(params.userid);
        if (!player || !player.IsValid())
            return;

        if (player in g_playerFOV){
            SetPlayerFOV(player, g_playerFOV[player]);
            DebugPrint("Restored FOV " + g_playerFOV[player] + " for player " + GetPlayerName(player));
        }
        if (player in g_centeredProjectiles){
            local weapon = player.GetActiveWeapon()
            weapon.AddAttribute("centerfire projectile", 1, 1)
            DebugPrint("Restored centered projectiles for player " + GetPlayerName(player))
        }
        else{
            local weapon = player.GetActiveWeapon()
            weapon.RemoveAttribute("centerfire projectile")
        }
    }catch(e){
        DebugPrint("Error in player_spawn event: " + e);
    }
    EntFireByHandle(g_scriptEntity, "RunScriptCode", "ShowTextsOnSpawn()", 0.01, null, null)


    }
OnGameEvent_player_say = function(EventData)
{
    local words = split(EventData.text, " ", true);
    local strTextFirstWord = words[0];

    if (strTextFirstWord.len() > 1 && strTextFirstWord[0] == '!'){
        local command = strTextFirstWord.slice(1).tolower();
        local hPlayer = GetPlayerFromUserID(EventData.userid);

        switch (command){
            case "fov":
                if (words.len() > 1){
                    try {
                        local fovValue = words[1].tointeger();
                        // Limit FOV to reasonable values
                        if (fovValue >= 90 && fovValue <= 120){
                            g_playerFOV[hPlayer] <- fovValue; // Store the FOV setting
                            SetPlayerFOV(hPlayer, fovValue);
                            DebugPrint("Set FOV to " + fovValue + " for player " + hPlayer);
                        }

                    } catch (e) {
                        DebugPrint("Invalid FOV value exception: " + e);
                    }
                }
                break;

            case "shader":
                if (words.len() > 1){
                    try {
                        local shaderValue = words[1].tointeger();
                        if (shaderValue == 1){
                            hPlayer.SetScriptOverlayMaterial("effects/shaders/hl")

                        }
                        else if (shaderValue == 2){
                            hPlayer.SetScriptOverlayMaterial("effects/shaders/pixelization")
                        }
                        else if (shaderValue == 0){
                            hPlayer.SetScriptOverlayMaterial("")
                        }

                    }catch (e) {
                        DebugPrint("Invalid shader value");
                    }
                }
                break;
            case "center":
                if (words.len() > 1){
                    try {
                        local centerValue = words[1].tointeger();
                        local weapon = hPlayer.GetActiveWeapon()
                        if (centerValue == 1){
                            g_centeredProjectiles[hPlayer] <- true
                            weapon.AddAttribute("centerfire projectile", 1, 1)
                        }
                        else if (centerValue == 0){
                            weapon.RemoveAttribute("centerfire projectile")
                            if (hPlayer in g_centeredProjectiles){
                                delete g_centeredProjectiles[hPlayer]
                            }
                        }
                    }catch(e){
                    DebugPrint("Invalid centered projectiles value");
                    }
                }
                break;
            
            /*case "arms":
                if (words.len() > 1){
                    try {
                        local armsValue = words[1].tointeger();
                        local hWeapon = hPlayer.GetActiveWeapon()
                        local arm = GetPropEntity(hPlayer, "m_hViewModel")
                        local weps
                        if (armsValue ==  3){
                            weps = GetPlayerWeapons(hPlayer)

                            foreach(idx, weapon in weps){
                                if (weapon && weapon.IsValid()){
                                    //patrick
                                    DebugPrint("Setting arms to 3. Active weapon: " + weapon)
                                    weapon.SetModelSimple("models/weapons/c_models/opfor2/c_soldier_arms.mdl")
                                    weapon.SetCustomViewModel("models/weapons/c_models/opfor2/c_soldier_arms.mdl")
                                }
                            }
                        }
                        else if (armsValue ==  2){
                            weps = GetPlayerWeapons(hPlayer)

                            foreach(idx, weapon in weps){
                                if (weapon && weapon.IsValid()){
                                    //patrick
                                    DebugPrint("Setting arms to 2. Active weapon: " + weapon)
                                    weapon.SetModelSimple("models/weapons/c_models/opfor2/c_soldier_arms.mdl")
                                    weapon.SetCustomViewModel("models/weapons/c_models/opfor2/c_soldier_arms.mdl")
                                }
                            }
                        }
                        else if (armsValue == 1)
                        {

                            weps = GetPlayerWeapons(hPlayer)
                            foreach(idx, weapon in weps)
                            {
                                if (weapon && weapon.IsValid())
                                {
                                    DebugPrint("Setting arms to 1. Active weapon: " + weapon)
                                    weapon.SetModelSimple("models/weapons/c_models/snoop/c_soldier_arms.mdl")
                                    weapon.SetCustomViewModel("models/weapons/c_models/snoop/c_soldier_arms.mdl")
                                }
                            }

                        }
                        else if (armsValue == 0)
                        {
                            weps = GetPlayerWeapons(hPlayer)
                            foreach(idx, weapon in weps)
                            {
                                if (weapon && weapon.IsValid())
                                {
                                    DebugPrint("Setting arms to 0. Active weapon: " + weapon)
                                    weapon.SetModelSimple("models/weapons/c_models/c_soldier_arms.mdl")
                                    weapon.SetCustomViewModel("models/weapons/c_models/c_soldier_arms.mdl")
                                }
                            }

                        }
                    }
                    catch(e){
                    DebugPrint("Invalid arms value exception: " + e);
                    }
                }
                */
                 
        }
    }
}
    OnGameEvent_teamplay_round_win = function(params)
    {
        g_overtime = false
    }

    OnGameEvent_rocket_jump = function(params)
    {
        local player = GetPlayerFromUserID(params.userid)
        local playerName = GetPlayerName(player)
        local playerIndex = player.entindex()
        DebugPrint("[OnRocketJump] Player jumped:" + playerName + ". Added to g_rocketJumpState")
        g_rocketJumpState[playerIndex] <- true

        // Check all zones for this player


        if (playerIndex in g_validExtenderSplash)
        {
            ExtenderLogic(player)
            DebugPrint("[OnRocketJump] validExtenderSplash was TRUE: firing ExtenderLogic")
        }
    }

    OnGameEvent_rocket_jump_landed = function(params)
    {

        /*local player = GetPlayerFromUserID(params.userid)
        local playerName = GetPlayerName(player)
        local playerIndex = player.entindex()
        local stateTables = [
            g_rocketJumpState,
            g_validExtenderSplash,
            g_validExtenderThrow,
            g_validExtenderAttempt,
            g_validZoneExtenderAttempt,
            g_validInstadetSplash,
            g_validInstadetExtenderAttempt,
            g_awardInstadetExtender
        ]
        foreach (table in stateTables)
        {
            if (playerIndex in table)
            {
                delete table[playerIndex]
                DebugPrint("[OnRocketJumpLanded] Deleted " + playerName + " from state table" + table)
            }
        }*/

    }

    OnGameEvent_pass_get = function(params)
    {
       OnGet(params)
    }

    OnGameEvent_pass_pass_caught = function(params)
    {
        OnCatch(params)
    }

    OnGameEvent_pass_free = function(params)
    {
        OnBallFree(params)
    }

    OnGameEvent_pass_ball_stolen = function(params)
    {
        local attacker = EntIndexToHScript(params.attacker)
        local victim = EntIndexToHScript(params.victim)
        local attackerName = GetPlayerName(attacker)
        local victimName = GetPlayerName(victim)
        local attackerTeam = GetPropInt(attacker, "m_iTeamNum")
        local victimTeam = GetPropInt(victim, "m_iTeamNum")
        local victimTeamName = GetTeamName(victimTeam)
        local lostPoints = g_pendingPoints[victimTeam]
        g_pendingPoints[victimTeam] = 0
        g_pendingPoints[attackerTeam] = POINTS_STEAL
        g_extenderChainCount[attackerTeam] = 0
        g_extenderChainCount[victimTeam] = 0
        SetScreenText("Steal! (+" + POINTS_STEAL.tointeger() + ")", g_teamColor[attackerTeam], 0, 3)
        SetScreenText(victimTeamName + " lost " + lostPoints.tointeger() + " points!", g_teamColor[victimTeam], 1, 3)
        SetScreenText("", "255 255 255", 2, 3)
        SetScreenText("", "255 255 255", 3, 3)
        SetScreenText("", "255 255 255", 4, 3)
        //SetScreenText("TOTAL: " + g_pendingPoints[attackerTeam].tointeger(), GetTotalPointsColor(g_pendingPoints[attackerTeam], "screen"), 5, 3)
        SetChatText("Steal!", POINTS_STEAL.tointeger())
    }

    OnGameEvent_pass_score = function(params)
    {
        local scorer = EntIndexToHScript(params.scorer)
        local team = scorer.GetTeam()
        local pendingPoints = g_pendingPoints[team]
        local oldTotal = g_teamScores[team]
        local game_round_win = Entities.FindByClassname(null, "game_round_win");
        local timer = g_timerEntity

        SetScreenText("GOAL!!! (+" + pendingPoints.tointeger() + ")", g_teamColor[team], 4, 3)
        SetChatText("GOAL!!!", pendingPoints.tointeger())
        g_teamScores[team] += pendingPoints
        if (g_last5Sec == true){
            timer.AcceptInput("AddTime", "4", null, null)
        }
        local bluScore = g_teamScores[BLU_TEAM]
        local redScore = g_teamScores[RED_TEAM]
        if (g_overtime == true){
            if (bluScore != redScore){
                if (redScore > bluScore){
                    SetPropInt(g_teamManagers[RED_TEAM], "m_nFlagCaptures", 1)
                    //EntFireByHandle(bluGoal, "AddOutput", "points 1", 0, null, null)
                    //SetPropInt(gamerules, "m_iWinningTeam", 2)
                    //DebugPrint("RED team winning!")

                }
                else if (bluScore > redScore){
                    SetPropInt(g_teamManagers[BLU_TEAM], "m_nFlagCaptures", 1)
                    //EntFireByHandle(redGoal, "AddOutput", "points 1", 0, null, null)
                    //SetPropInt(gamerules, "m_iWinningTeam", 3)
                    //DebugPrint("BLU team winning!")
                }
            }
        }
        UpdatePDHud()
        g_pendingPoints[RED_TEAM] <- 0
        g_pendingPoints[BLU_TEAM] <- 0
        g_extenderChainCount[RED_TEAM] <- 0
        g_extenderChainCount[BLU_TEAM] <- 0
    }

    OnGameEvent_teamplay_broadcast_audio = function(params)
    {
        /*if (params.sound == "Passtime.BallSpawn"){
            //SetScreenText("", "255 255 255", 0, 3)
            //SetScreenText("", "255 255 255", 1, 3)
            //SetScreenText("", "255 255 255", 2, 3)
            //SetScreenText("", "255 255 255", 3, 3)
            //SetScreenText("", "255 255 255", 4, 3)
            //SetScreenText("", "255 255 255", 5, 3)
        }*/
        // Disabled with new text system
    }

    OnScriptHook_OnTakeDamage = function(params)
    {
        if (!(params.const_entity == g_ballEntity)){
           return
        }
        local attacker = params.attacker
        local attackerName = GetPlayerName(attacker)
        local attackerTeam = GetPropInt(attacker, "m_iTeamNum")

        local damageType = params.damage_type
        local damage = params.damage
        local previousState = null
        local attackerIndex = attacker.entindex()
        local splashTime = Time()
        g_lastBallDamager = attacker

        if (g_ballState["state"] = "blue")
            previousState = BLU_TEAM
        else if (g_ballState["state"] = "red")
            previousState = RED_TEAM
        else if (g_ballState["state"] = "neutral")
            previousState = NEUTRAL
        else
            previousState = NEUTRAL

        function GetDamageType(damageType, damage){
            if (damageType == DMGTYPE_ROCKET && damage == DMG_DIRECT) return "direct";
            else if (damageType == DMGTYPE_ROCKET) return "splash";
            else if (damageType == 134221952) return "melee";
            return null;
        }

        local dt = GetDamageType(params.damage_type, params.damage)

        function HandleTeamDamage(dt, attackerIndex, splashTime, attackerName){
            DebugPrint("previousState: " + previousState + " attackerTeam: " + attackerTeam)
            if (previousState == attackerTeam || previousState == NEUTRAL){
                if (dt == "splash" || dt == "direct"){
                    g_validExtenderSplash[attackerIndex] <- true
                    g_splashTime[attackerIndex] <- splashTime

                    if (dt == "direct"){
                        g_validInstadetSplash[attackerIndex] <- true
                        DebugPrint("[OnTakeDamage] g_validInstadetSplash[" + attackerIndex + "] = true")
                    } else if (attackerIndex in g_validInstadetSplash) {
                        delete g_validInstadetSplash[attackerIndex]
                    }

                    if (attackerIndex in g_validExtenderThrow && attackerIndex in g_rocketJumpState){
                        foreach(zone, zoneData in g_zoneEntities){
                            local zoneComplete = CheckZoneComplete(zone)
                            local entityOwnershipValid = CheckEntityOwnership(zone)

                            if (zoneComplete && entityOwnershipValid){
                                DebugPrint("[OnTakeDamage] Zone " + zone + " meets requirements for " + GetPlayerName(attackerIndex))
                                g_validZoneExtenderAttempt[attackerIndex] <- { zone = zone }
                                DebugPrint("[OnTakeDamage] Added to zone extender attempt list for zone " + zone)
                            }
                        }
                    }
                }
            }
        }

        HandleTeamDamage(dt, attackerIndex, splashTime, attackerName)
    }

})

::GetPlayerName <- function(player)
{
    return GetPropString(player, "m_szNetname")
}

::EnumerateTable <- function(table) {
    printl("{");
    foreach (key, value in table) {
        printl("    " + key + ": " + value);
    }
    printl("}")
}

::SetPlayerFOV <- function(player, fov)
{
    if (!player || !player.IsValid())
        return;
    SetPropInt(player, "m_iFOV", fov);
}

::GetPlayerWeapons <- function(player)
{
    local wlist = {}
    for (local i = 0; i < MAX_WEAPONS; i++){
        local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null)
            continue
        wlist[i] <- weapon
    }
    return wlist
}

::OnBallDirect <- function(attacker)
{
    local attackerName = GetPlayerName(attacker)
    local attackerTeam = GetPropInt(attacker, "m_iTeamNum")

}

//------------------------------------------------------------------------------------------------------
//////////////////
// Event handlers
//////////////////
//------------------------------------------------------------------------------------------------------

::OnBallFree <- function(params)
{
    local player = EntIndexToHScript(params.owner)
    local attacker = EntIndexToHScript(params.attacker)
    local playerName = GetPlayerName(player)
    local attackerName = GetPlayerName(attacker)
    local throwTime = Time()
    local playerIndex = player.entindex()

    if (playerIndex in g_splashTime){
        g_splashTime[playerIndex] = null
    }

    if (playerIndex in g_validZoneExtenderAttempt){
        delete g_validZoneExtenderAttempt[playerIndex]
        DebugPrint ("[OnBallFree] Player had validZoneExtenderAttempt: " + playerName + ". Removing it.")
    }
    if (playerIndex in g_validExtenderAttempt){
        delete g_validExtenderAttempt[playerIndex]
        DebugPrint ("[OnBallFree] Player had validExtenderAttempt: " + playerName + ". Removing it.")
    }
    if (playerIndex in g_validInstadetExtenderAttempt){
        delete g_validInstadetExtenderAttempt[playerIndex]
        DebugPrint ("[OnBallFree] Player had validInstadetExtenderAttempt: " + playerName + ". Removing it.")
    }
    if (playerIndex in g_awardInstadetExtender){
        delete g_awardInstadetExtender[playerIndex]
        DebugPrint ("[OnBallFree] Player had validInstadetExtenderAttempt: " + playerName + ". Removing it.")
    }


    DebugPrint("[OnBallFree] Owner: " + playerName)
    g_ballState["lastCarrier"] = player
    g_ballState["currentCarrier"] = null
    g_lastThrowTime = throwTime

    if (playerIndex in g_rocketJumpState){
        local velocity = player.GetAbsVelocity()
        local speed = velocity.Length()
        g_throwVelocity = speed
        g_validExtenderThrow[playerIndex] <- true
        DebugPrint("[OnBallFree] Player was jumping when thrown: " + playerName + " (extender throw valid)")
    }
    else{
        DebugPrint("[OnBallFree] Player was not jumping when thrown: " + playerName + " (extender throw invalid)")
        if (playerIndex in g_validExtenderThrow){
            delete g_validExtenderThrow[playerIndex]
        }
    }
}

::OnCatch <- function(params)
{
    local carrier = EntIndexToHScript(params.catcher)
    g_ballState["currentCarrier"] = carrier
    local thrower = EntIndexToHScript(params.passer)
    g_ballState["lastCarrier"] = thrower
    local carrierName = GetPlayerName(carrier)
    local carrierTeam = GetPropInt(carrier, "m_iTeamNum")
    local carrierTeamName = GetTeamName(carrierTeam)
    local lastCarrier = g_ballState["lastCarrier"]
    local lastCarrierName = GetPlayerName(lastCarrier)
    local lastTeam = GetPropInt(lastCarrier, "m_iTeamNum")
    local lastTeamName = GetTeamName(lastTeam)
    local distance = params.dist
    local duration = params.duration
    local caught = true
    local wasFanned = g_ballFanned
    g_ballFanned = false
    local carrierSpeed = carrier.GetAbsVelocity().Length()
    // If possession changed, treat as interception
    if (lastTeam != carrierTeam){
        DebugPrint("[OnCatch] lastTeam != carrierTeam. Ball intercepted by " + carrierName + " of team " + carrierTeam)
        local lostPoints = g_pendingPoints[lastTeam]
        local points = POINTS_TURNOVER
        local speedRatio = carrierSpeed / POINTS_EXTENDER_VELOCITY_CAP
        local speedMultiplier = POINTS_INTERCEPT_VELOCITY_BASE + pow(POINTS_INTERCEPT_VELOCITY_SCALE * speedRatio, 2)
        points *= speedMultiplier
        g_pendingPoints[lastTeam] = 0
        g_pendingPoints[carrierTeam] = points.tointeger()
        g_extenderChainCount[carrierTeam] = 0
        g_extenderChainCount[lastTeam] = 0
        SetScreenText("Intercept! (+" + points.tointeger() + ")", g_teamColor[carrierTeam], 0, 3)
        SetScreenText(lastTeamName + " lost " + lostPoints.tointeger() + " points!", g_teamColor[lastTeam], 1, 3)
        SetChatText("Intercept!", points.tointeger())
        SetScreenText("", "255 255 255", 2, 3)
        SetScreenText("", "255 255 255", 3, 3)
        SetScreenText("", "255 255 255", 4, 3)
        //SetScreenText("TOTAL: " + g_pendingPoints[carrierTeam].tointeger(), GetTotalPointsColor(g_pendingPoints[carrierTeam], "screen"), 5, 3)

    }
    // Do nothing if the ball was caught by the thrower
    else if (lastCarrier == carrier){
        DebugPrint("[OnCatch] lastCarrier == carrier. Ball caught by thrower!")
    }
    // Else, treat as a pass
    else{
        DebugPrint("[OnCatch] Ball changed hands (same team). Caught by " + carrierName + " of team " + carrierTeam + ". Firing HandleHandoff.")
        HandleHandoff(carrier, lastCarrier, caught, duration, wasFanned)
    }

}

::OnGet <- function(params)
{
    local carrier = EntIndexToHScript(params.owner)
    local carrierName = GetPlayerName(carrier)
    local carrierTeam = GetPropInt(carrier, "m_iTeamNum")
    local carrierTeamName = GetTeamName(carrierTeam)
    local carrierIndex = carrier.entindex()
    local lastCarrier = g_ballState["lastCarrier"]
    local lastCarrierName = lastCarrier ? GetPlayerName(lastCarrier) : "none"
    local lastTeam = lastCarrier ? GetPropInt(lastCarrier, "m_iTeamNum") : -1
    local lastTeamName = GetTeamName(lastTeam)
    local caught = false
    local ballFreeTime = g_lastThrowTime
    local ballGetTime = Time()
    local ballLooseDuration = ballGetTime - ballFreeTime
    local lastBallDamager = g_lastBallDamager

    local wasFanned = g_ballFanned
    DebugPrint("[OnGet] Was fanned?: " + wasFanned)
    g_ballFanned = false

    local ballSplashDuration = null
    if (carrierIndex in g_splashTime && g_splashTime[carrierIndex] != null){
        local splashTime = g_splashTime[carrierIndex]

        ballSplashDuration = ballGetTime - splashTime
        DebugPrint("[OnGet] Splash-get. Splash time: " + g_splashTime[carrierIndex] + ". Splash-to-get duration: " + ballSplashDuration)

    }

    g_ballState["currentCarrier"] = carrier
    if (lastTeam == -1){
        return
    }
    if (lastTeam != carrierTeam){
        DebugPrint("[OnGet] lastTeam != carrierTeam: Ball turnover! Thrown by " + lastCarrierName + ", caught by " + carrierName + " of team " + carrierTeam)
        local lostPoints = g_pendingPoints[lastTeam]
        g_pendingPoints[lastTeam] = 0
        g_pendingPoints[carrierTeam] = 0
        g_extenderChainCount[carrierTeam] = 0
        g_extenderChainCount[lastTeam] = 0

        SetScreenText("Turnover!", g_teamColor[carrierTeam], 0, 3)
        SetScreenText(lastTeamName + " lost " + lostPoints.tointeger() + " points!", g_teamColor[lastTeam], 1, 3)
        SetChatText("Turnover!", null)
        SetScreenText("", "255 255 255", 2, 3)
        SetScreenText("", "255 255 255", 3, 3)
        SetScreenText("", "255 255 255", 4, 3)
        //SetScreenText("TOTAL: " + g_pendingPoints[carrierTeam].tointeger(), GetTotalPointsColor(g_pendingPoints[carrierTeam], "screen"), 5, 3)
    }
    else if (lastCarrier == carrier){
        DebugPrint("[OnGet] lastCarrier == carrier. Ball get by thrower!")
        if (carrierIndex in g_validExtenderAttempt && carrierIndex in g_validInstadetExtenderAttempt)
        {
        g_awardInstadetExtender[carrierIndex] <- true
        OnExtender(carrier, ballSplashDuration)
        }
        else if (carrierIndex in g_validExtenderAttempt)
        {
        OnExtender(carrier, ballSplashDuration)
        g_awardInstadetExtender.clear()

        }
    }
    else{
    // Else, treat as a pass
    DebugPrint("[OnGet] Ball changed hands, same team. Ball get by " + carrierName + " of team " + carrierTeam + ". Firing HandleHandoff.")
    HandleHandoff(carrier, lastCarrier, caught, ballLooseDuration, wasFanned)
    }
}

//------------------------------------------------------------------------------------------------------
//////////////////
// Extender logic
//////////////////
//------------------------------------------------------------------------------------------------------

::ExtenderLogic <- function(player)
{

    local playerName = GetPlayerName(player)
    local playerIndex = player.entindex()
    if ((playerIndex in g_validInstadetSplash) && (playerIndex in g_validExtenderSplash) && (playerIndex in g_validExtenderThrow)){
        local velocity = player.GetAbsVelocity()
        local speed = velocity.Length()
        g_validInstadetExtenderAttempt[playerIndex] <- true
        g_validExtenderAttempt[playerIndex] <- true
        DebugPrint("[ExtenderLogic] All extender logic passed + instadet: " + playerName + ". validInstadetExtenderAttempt set to TRUE")
    }
    else if ((playerIndex in g_validExtenderSplash) && (playerIndex in g_validExtenderThrow)){
        local velocity = player.GetAbsVelocity()
        local speed = velocity.Length()
        g_validExtenderAttempt[playerIndex] <- true
        g_validInstadetExtenderAttempt.clear()
        g_awardInstadetExtender.clear()
        DebugPrint("[ExtenderLogic] validExtenderSplash TRUE and validExtenderThrow TRUE for: " + playerName + ". validExtenderAttempt set to TRUE")
    }
    else{
        DebugPrint("[ExtenderLogic] validExtenderSplash FALSE or validExtenderThrow FALSE for: " + playerName + ". validExtenderAttempt set to FALSE")
        return
        g_validInstadetExtenderAttempt.clear()
        g_awardInstadetExtender.clear()
    }
}

::OnExtender <- function(carrier, duration)
{
    local zt
    local carrierIndex = carrier.entindex()
    DebugPrint("[OnExtender] Extender awarded for " + GetPlayerName(carrier) + " with cleanness of " + duration + " seconds")
    local cleanness = duration
    local points = POINTS_EXTENDER
    local carrierTeam = GetPropInt(carrier, "m_iTeamNum")

    // Calculate points based on cleanness
    if (cleanness > 3){
        points *= 0
        DebugPrint("Too sloppy. No points.")
    }
    else if (carrierIndex in g_awardInstadetExtender){
        points *= 1.5
        DebugPrint("Instadet extender!")
        SetScreenText("Instadet extender! (x1.5)", "255 0 255", 2, 3)
        delete g_awardInstadetExtender[carrierIndex]
    }
    else if (cleanness < 0.02){
        points *= 1.2
        DebugPrint("Clean!")
        SetScreenText("Clean!", "0 255 0", 2, 3)
    }
    else if (cleanness > 0.4){
        points *= 0.8
        DebugPrint("Sloppy!")
        SetScreenText("Sloppy!", "255 0 0", 2, 3)
    }
    else{
        points *= 1.0
        DebugPrint("Normal!")
        SetScreenText("", "255 255 255", 2, 3)
    }


    // Calculate points based on speed
    local speed = g_throwVelocity
    local speedRatio = speed / POINTS_EXTENDER_VELOCITY_CAP
    local speedMultiplier = POINTS_EXTENDER_VELOCITY_BASE + pow(POINTS_EXTENDER_VELOCITY_SCALE * speedRatio, 2)
    DebugPrint("[OnExtender] Speed multiplier: " + speedMultiplier)
    points *= speedMultiplier
    if (speed >= 1400){
        SetScreenText("NUCLEAR! (" + speed.tointeger() + " HU/s)", "253 156 0", 1, 3)
        DebugPrint("Nuclear!")
    }
    else if (speed >= 1150){
        SetScreenText("Very fast! (" + speed.tointeger() + " HU/s)", "60 212 131", 1, 3)
        DebugPrint("Very fast!")
    }
    else if (speed >= 950){
        SetScreenText("Fast! (" + speed.tointeger() + " HU/s)", "150 201 92", 1, 3)
        DebugPrint("Fast!")
    }
    else if (speed <= 350){
        SetScreenText("World's Slowest Jeff! (" + speed.tointeger() + " HU/s)", "150 150 150", 1, 3)
        DebugPrint("Very Slow!")
        points *= 0.5
    }
    else if (speed <= 600){
        SetScreenText("Slow! (" + speed.tointeger() + " HU/s)", "186 100 100", 1, 3)
        DebugPrint("Slow!")
    }
    else{
        SetScreenText("", "255 255 255", 1, 3)
        DebugPrint("Normal speed!")
    }

    // set combo length
    if (!(carrierTeam in g_extenderChainCount))
        g_extenderChainCount[carrierTeam] <- 1; 
    else
        g_extenderChainCount[carrierTeam]++;
        
    local chainLength = carrierTeam in g_extenderChainCount ? g_extenderChainCount[carrierTeam] : 1;
    for (local i = 1; i < chainLength; i++)
        points = (points * POINTS_CHAIN_MULTIPLIER).tointeger();
    local chainText = chainLength > 1 ? "[x" + chainLength + " COMBO!]" : "";
    DebugPrint("[OnExtender] Current zone extender attempts:")
    EnumerateTable(g_validZoneExtenderAttempt)

    // Check for special moves
    if (carrierIndex in g_validZoneExtenderAttempt){
        DebugPrint("Zone extender awarded!")
        local zoneId = g_validZoneExtenderAttempt[carrierIndex].zone
        DebugPrint("@@@ points before zoneid: " + points)
        DebugPrint("Zone extender ID: " + zoneId)
        if (zoneId == 1){
            g_specFlag = 1
            points *= 2
            DebugPrint("Zone extender x2!")
        }
        else if (zoneId == 2){
            g_specFlag = 2
            points *= 3
            DebugPrint("Zone extender x3")
        }
        else if (zoneId == 3){
            g_specFlag = 3
            points *= 4
            DebugPrint("Zone extender x4!")
        }
        else if (zoneId == 4){
            g_specFlag = 4
            points *= 5
            DebugPrint("Zone extender x5!")
        }
        else if (zoneId == 5){
            g_specFlag = 5
            points *= 6
            DebugPrint("Zone extender x6!")
        }
        else if (zoneId == 6){
            g_specFlag = 6
            points *= 10
            DebugPrint("Zone extender x7!")
        }
        else if (zoneId == 7 || zoneId == 8){
            g_specFlag = 7
            points *= 2
            DebugPrint("Zone extender x2! (Low Taper)")
        }
        else if (zoneId == 9 || zoneId == 10){
            g_specFlag = 9
            points *= 2
            DebugPrint("Zone extender x2! (Lower mid)")
        }
        else if (zoneId == 11 || zoneId == 12){
            g_specFlag = 11
            points *= 1.25

        }
        else if (zoneId == 13 || zoneId == 14){
            g_specFlag = 13
            points *= 1.5
            DebugPrint("Zone extender x1.5! (Pibble)")
        }
        else if (zoneId == 17){
            g_specFlag = 17
            points *= 2
            DebugPrint("Pizza! x2")
        }
        zt = GetZoneText(zoneId)
    }

    if (carrierIndex in g_validZoneExtenderAttempt){
        delete g_validZoneExtenderAttempt[carrierIndex]
        DebugPrint("[OnExtender] Extender processing finished. Zone extender attempt deleted!")
    }
    
    // Show on screen
    SetScreenText("Extender! (+" + points.tointeger() + ")", GetActionPointsColor(points, "screen"), 0, 3)
    SetScreenText(chainText, "255 255 255", 4, 3)

    g_pendingPoints[carrierTeam] += points.tointeger()
    if (g_specFlag == 0){
        SetChatText("Extender!", points.tointeger())
    }
    else{
        local zone = g_specFlag
        local zt = GetZoneText(zone)
        SetChatText(zt, points.tointeger())
        SetScreenText(zt, "190 144 255", 3, 3)
    }
}

//------------------------------------------------------------------------------------------------------
//////////////////
// Handoff logic
//////////////////
//------------------------------------------------------------------------------------------------------

::HandleHandoff <- function(carrier, lastCarrier, caught, ballLooseDuration, wasFanned)
{
    local carrier = carrier
    local carrierIndex = carrier.entindex()
    local lastCarrier = lastCarrier
    local lastCarrierIndex = lastCarrier.entindex()
    local carrierName = GetPlayerName(carrier)
    local lastCarrierName = GetPlayerName(lastCarrier)
    local caught = caught
    local duration = ballLooseDuration
    local wasFanned = wasFanned
    local lastDamager = null
    if (!(carrierIndex in g_rocketJumpState))
    {
        DebugPrint("[HandleHandoff] Not a handoff, receiver not jumping")
        return false
    }
    // 3 = fanned and either splashed or caught. Clean fandoff
    // 2 = fanned, not splashed, not caught. Weak fandoff
    // 1 = Not fanned, not splashed, not caught. Weak handoff
    // 0 = Not fanned, splashed or caught. Clean handoff
    if (g_lastBallDamager != null)
    {
    lastDamager = g_lastBallDamager.entindex()
    }
    DebugPrint ("[HandleHandoff] lastDamager: " + lastDamager)
    if (carrierIndex == lastDamager && caught == false && duration < 3 && wasFanned == true)
    {
        OnHandoff(carrier, lastCarrier, duration, "3")
        DebugPrint("[HandleHandoff] Handoff case: Fanned and splashed on pickup. Got by " + carrierName + ". Loose for " + duration)
    }
    else if (carrierIndex in g_validExtenderSplash && caught == false && duration < 3)
    {
        OnHandoff(carrier, lastCarrier, duration, "0")
        DebugPrint("[HandleHandoff] Handoff case - Not fanned, splashed on pickup. Got by " + carrierName + ". Loose for " + duration)
    }
    else if (caught == true && wasFanned == true)
    {
        OnHandoff(carrier, lastCarrier, duration, "3")
        DebugPrint("[HandleHandoff] Handoff case: Fanned and caught by " + carrierName + ". Loose for " + duration)
    }
    else if (caught == true)
    {
        OnHandoff(carrier, lastCarrier, duration, "0")
        DebugPrint("[HandleHandoff] Handoff case: Not fanned, caught by " + carrierName + ". Loose for " + duration)
    }
    else
    {
        if (wasFanned == true && duration < 3)
        {
            DebugPrint("[HandleHandoff] Handoff case: Fanned, not splashed, not caught. Was within 2.5 seconds. From " + lastCarrierName + " to " + carrierName)
            OnHandoff(carrier, lastCarrier, duration, "2")
        }
        else if (duration < 3)
        {
            DebugPrint("[HandleHandoff] Handoff case: Not fanned, not splashed, not caught. Was within 3 seconds. " + lastCarrierName + " to " + carrierName)
            OnHandoff(carrier, lastCarrier, duration, "1")
        }
        else
        {
            DebugPrint("[HandleHandoff] No handoff awarded. Ball loose for " + duration)
        }


    }
}

::OnHandoff <- function(carrier, lastCarrier, ballLooseDuration, mid)
{
    DebugPrint ("Handoff awarded from " + GetPlayerName(lastCarrier) + " to " + GetPlayerName(carrier))
    local points = POINTS_HANDOFF
    local duration = ballLooseDuration
    local carrierTeam = GetPropInt(carrier, "m_iTeamNum")
    local velocity = carrier.GetAbsVelocity()
    local speed = velocity.Length()
    local speedRatio = speed / POINTS_EXTENDER_VELOCITY_CAP
    local speedMultiplier = POINTS_EXTENDER_VELOCITY_BASE + pow(POINTS_EXTENDER_VELOCITY_SCALE * speedRatio, 2)
    local formattedDuration = format("%.2f", duration)
    local ballHeight = g_ballState["position"].z
    local heightMult = POINTS_HANDOFF_HEIGHT_BASE + pow(POINTS_HANDOFF_HEIGHT_SCALE * (ballHeight / POINTS_HANDOFF_HEIGHT_CAP), 2)
    local isReal = mid

    DebugPrint("Handoff points before height multiplier: " + points.tointeger())
    points *= heightMult
    DebugPrint("Handoff points after height multiplier: " + points.tointeger())

    if (ballHeight >= 1100)
    {
        DebugPrint("Pibble!")
        SetScreenText("Pibby! (" + ballHeight.tointeger() + " HU)", "255 0 255", 2, 3)
    }
    else if (ballHeight >= 950)
    {
        DebugPrint("Freaky high!")
        SetScreenText("Freaky high! (" + ballHeight.tointeger() + "HU)", "0 255 255", 2, 3)
    }
    else if (ballHeight >= 800)
    {
        DebugPrint("Very high!")
        SetScreenText("Very high! (" + ballHeight.tointeger() + " HU)", "0 255 0", 2, 3)
    }
    else if (ballHeight >= 600)
    {
        DebugPrint("High!")
        SetScreenText("High! (" + ballHeight.tointeger() + " HU)", "150 255 0", 2, 3)
    }
    else
    {
        DebugPrint("Normal!")
        SetScreenText("", "255 255 255", 2, 3)
    }

    points *= speedMultiplier
    if (speed >= 1400)
    {
        SetScreenText("NUCLEAR! (" + speed.tointeger() + " HU/s)", "253 156 0", 1, 3)
        DebugPrint("Nuclear!")
    }
    else if (speed >= 1150)
    {
        SetScreenText("Very fast! (" + speed.tointeger() + " HU/s)", "60 212 131", 1, 3)
        DebugPrint("Very fast!")
    }
    else if (speed >= 950)
    {
        SetScreenText("Fast! (" + speed.tointeger() + " HU/s)", "150 201 92", 1, 3)
        DebugPrint("Fast!")
    }
    else if (speed <= 350)
    {
        SetScreenText("Too slow! (" + speed.tointeger() + " HU/s)", "255 0 0", 1, 3)
        DebugPrint("Very Slow!")
        points *= 0
    }
    else if (speed <= 600)
    {
        SetScreenText("Slow! (" + speed.tointeger() + " HU/s)", "186 100 100", 1, 3)
        DebugPrint("Slow!")
    }
    else
    {
        SetScreenText("", "255 255 255", 1, 3)
        DebugPrint("Normal speed!")
    }

    // check for fan and proper handoff
    if (isReal == "3")
    {
        points *= 1.25
        DebugPrint("Clean fandoff! (x1.25)")
        SetScreenText("Clean fan handoff!  (+" + points.tointeger() + ")", GetActionPointsColor(points, "screen"), 0, 3)
    }
    else if (isReal == "2")
    {
        points *= 1.15
        DebugPrint("Weak fandoff! (x1.15)")
        SetScreenText("Fan handoff!  (+" + points.tointeger() + ")", GetActionPointsColor(points, "screen"), 0, 3)
    }
    else if (isReal == "0")
    {
        points *= 1.25
        DebugPrint("Handoff! (x1.25)")
        SetScreenText("Handoff! (+" + points.tointeger() + ")", GetActionPointsColor(points, "screen"), 0, 3)
    }
    else if (isReal == "1")
    {
        points *= 1
        DebugPrint("Weak handoff! (x1)")
        SetScreenText("Pass! (+" + points.tointeger() + ")", GetActionPointsColor(points, "screen"), 0, 3)
    }

    g_pendingPoints[carrierTeam] += points.tointeger()
    SetChatText("Handoff!", points.tointeger())
}

//------------------------------------------------------------------------------------------------------
//////////////////////
// Text/HUD functions
//////////////////////
//------------------------------------------------------------------------------------------------------

::CreateScreenText <- function()
{

    g_gt = SpawnEntityFromTable("game_text", {
        targetname = "gt",
        message = "Test",
        x = 0.2,
        y = 0.5,
        spawnflags = 0x1,
        holdtime = 0.0151,
        color = "255 255 255",
        channel = 0
    })
    SetPropBool(g_gt, "m_bForcePurgeFixedupStrings", true)
    SetScreenText("", "255 0 0", 0, 1)
    SetScreenText("", "0 255 0", 1, 1)
    SetScreenText("", "0 255 0", 2, 1)
    SetScreenText("", "0 255 0", 3, 1)
    SetScreenText("", "0 255 0", 4, 1)
    SetScreenText("", "0 255 0", 5, 1)
    g_gt.AcceptInput("Display", "", null, null)
}

::SetScreenText <- function(text, color, channel, duration)
    {
        local mx = 0.2
        local my = 0.5
        local wl = {}
        if (channel == 0){
            mx = 0.2
            my = 0.50
        }
        else if (channel == 1){
            mx = 0.2
            my = 0.53
        }
        else if (channel == 2){
            mx = 0.2
            my = 0.56
        }
        else if (channel == 3){
            mx = 0.2
            my = 0.59
        }
        else if (channel == 4){
            mx = -1
            my = 0.62
        }
        else if (channel == 5){
            mx = -1
            my = 0.65
        }
        else{
            DebugPrint("@@@@@@@@@@INVALID TEXT CHANNEL@@@@@@@@@@@@@@")
            mx = 0.5
            my = 0.5
        }
        g_gt.KeyValueFromFloat("x", mx)
        g_gt.KeyValueFromFloat("y", my)
        g_gt.KeyValueFromString("message", "")
        g_gt.KeyValueFromString("holdtime", "0.0000001")
        g_gt.KeyValueFromString("message", text)
        g_gt.KeyValueFromString("color", color)
        g_gt.KeyValueFromInt("holdtime", duration)
        g_gt.KeyValueFromInt("channel", channel)
        g_gt.AcceptInput("Display", "", null, null)
    }

::RefreshScreenText <- function()
{
    local redChanged = g_pendingPoints[RED_TEAM] != g_previousPendingPoints[RED_TEAM]
    local bluChanged = g_pendingPoints[BLU_TEAM] != g_previousPendingPoints[BLU_TEAM]
    local redPending = g_pendingPoints[RED_TEAM]
    local bluPending = g_pendingPoints[BLU_TEAM]
    if (redChanged || bluChanged)
    {
        if (redPending > bluPending)
        {
            SetScreenText("TOTAL: " + redPending, GetTotalPointsColor(redPending, "screen"), 5, 3)
        }
        else if (bluPending > redPending)
        {
            SetScreenText("TOTAL: " + bluPending, GetTotalPointsColor(bluPending, "screen"), 5, 3)
        }
        else if (redPending == bluPending)
        {
            SetScreenText("TOTAL: 0", GetTotalPointsColor(redPending, "screen"), 5, 3)
        }
    g_previousPendingPoints[RED_TEAM] = g_pendingPoints[RED_TEAM]
    g_previousPendingPoints[BLU_TEAM] = g_pendingPoints[BLU_TEAM]
    return true
    }
    return false
}

::GetTeamName <- function(team) // Team name for text strings in chat/screen messages
{
    if (team == RED_TEAM){
        return "RED"
    }
    else if (team == BLU_TEAM){
        return "BLU"
    }
    else{
        return "Unknown"
    }
}

::UpdatePDHud <- function() // Called on goal scored, updates PDHUD to current score totals
{
    if (!g_hudEntity){
        g_hudEntity = Entities.FindByClassname(null, "pd_logic")
        if (!g_hudEntity){
            DebugPrint("PD logic entity not found!")
            return
        }
    }
    else{
        local redScore = g_teamScores[RED_TEAM]
        local bluScore = g_teamScores[BLU_TEAM]
        SetPropInt(g_hudEntity, "m_nRedScore", redScore)
        SetPropInt(g_hudEntity, "m_nBlueScore", bluScore)
    }
}

::ShowTextsOnSpawn <- function()
{
    local redPending = g_pendingPoints[RED_TEAM]
    local bluPending = g_pendingPoints[BLU_TEAM]

    if (!(g_extenderChainCount[RED_TEAM] == 0 && g_extenderChainCount[BLU_TEAM] == 0)){
        local teamToUse = g_extenderChainCount[RED_TEAM] > 0 ? RED_TEAM : BLU_TEAM;
        local chainLength = teamToUse in g_extenderChainCount ? g_extenderChainCount[teamToUse] : 1;
        local chainText = chainLength > 1 ? "[x" + chainLength + " COMBO!]" : "";
        SetScreenText(chainText, "255 255 255", 4, 3)
    }


    if (redPending > bluPending){
        SetScreenText("TOTAL: " + redPending, GetTotalPointsColor(redPending, "screen"), 5, 3)
    }
    else if (bluPending > redPending){
        SetScreenText("TOTAL: " + bluPending, GetTotalPointsColor(bluPending, "screen"), 5, 3)
    }
    else if (redPending == bluPending){
        SetScreenText("TOTAL: 0", GetTotalPointsColor(redPending, "screen"), 5, 3)
    }

}

::SetChatText <- function(text, points)
{
    local ent = null
    local carrier = g_ballState["currentCarrier"]
    local carrierTeam = null
    local pending = null
    local teamcolor = null

    if (carrier == null || carrier == -1){
        carrierTeam = 0
    }
    else{
        carrierTeam = GetPropInt(carrier, "m_iTeamNum")
        pending = g_pendingPoints[carrierTeam].tointeger()
        teamcolor = g_teamChatColor[carrierTeam]
    }
    local carrierName = GetPlayerName(carrier)
    local colorwhite = "\x07FFFFFF"
    local message = null
    if (g_specFlag != 0){
        colorwhite = "\x07BE90FF"
        g_specFlag = 0
    }
    if (points != null && carrier !=  null){
        message = teamcolor + carrierName + ": " + colorwhite + text + GetActionPointsColor(points, "chat") + " (+" + points.tointeger() + ")" + GetTotalPointsColor(pending, "chat") + " [" + pending + "]"
    }
    else{
        message = colorwhite + text
    }
    while (ent = Entities.FindByClassname(ent, "player")){
        ClientPrint(ent, HUD_PRINTTALK, message);
    }
}

::GetActionPointsColor <- function(points, chat)
{
    if (chat == "screen"){
        if (points >= 1600)
            return "9 255 177"
        else if (points >= 1300)
            return "64 252 104"
        else if (points >= 1000)
            return "96 249 129"
        else if (points >= 800)
            return "112 243 140"
        else if (points >= 650)
            return "143 231 162"
        else if (points >= 500)
            return "175 219 184"
        else
            return "206 206 206"
    }
    else{
        if (points >= 1600)
            return "\x0709FFB1"
        else if (points >= 1300)
            return "\x0740FC68"
        else if (points >= 1000)
            return "\x0760F981"
        else if (points >= 800)
            return "\x0770F38C"
        else if (points >= 650)
            return "\x078FE7A2"
        else if (points >= 500)
            return "\x07AFDBB8"
        else
            return "\x07CECECE"
    }
}

::GetTotalPointsColor <- function(points, chat)
{
    if (chat == "screen"){
        if (points >= 25000)
            return "190 144 255"
        else if (points >= 17500)
            return "252 151 0"
        else if (points >= 10000)
            return "241 165 52"
        else if (points >= 5000)
            return "235 172 78"
        else if (points >= 3000)
            return "229 179 103"
        else if (points >= 1000)
            return "218 193 155"
        else
            return "206 206 206"
    }
    else{
        if (points >= 25000)
            return "\x07BE90FF"
        else if (points >= 17500)
            return "\x07FC9700"
        else if (points >= 10000)
            return "\x07F1A534"
        else if (points >= 5000)
            return "\x07EBAC4E"
        else if (points >= 3000)
            return "\x07E5B367"
        else if (points >= 1000)
            return "\x07DAC19B"
        else
            return "\x07CECECE"
    }
}

//------------------------------------------------------------------------------------------------------
//////////////////
// Game end logic
//////////////////
//------------------------------------------------------------------------------------------------------

::OnGameEnd <- function()
{
    local bluScore = g_teamScores[BLU_TEAM];
    local redScore = g_teamScores[RED_TEAM];
    local bluGoal = Entities.FindByName(null, "blue_goal")
    local redGoal = Entities.FindByName(null, "red_goal")
    local redPending = g_pendingPoints[RED_TEAM];
    local bluPending = g_pendingPoints[BLU_TEAM];
    local game_round_win = Entities.FindByClassname(null, "game_round_win");
    local carrierTeam = null
    local carrier = g_ballState["currentCarrier"]
    if (carrier != null){
        carrierTeam = GetPropInt(carrier, "m_iTeamNum")
    }
    // Calculate winning team
    if (bluScore > redScore && carrierTeam == BLU_TEAM){
        EntFireByHandle(game_round_win, "SetTeam", "3", -1, null, null);
        EntFireByHandle(game_round_win, "RoundWin", "", -1, null, null);
    }
    else if (redScore > bluScore && carrierTeam == RED_TEAM){
        EntFireByHandle(game_round_win, "SetTeam", "2", -1, null, null);
        EntFireByHandle(game_round_win, "RoundWin", "", -1, null, null);
    }
    else if (redScore == bluScore){
        EntFireByHandle(bluGoal, "AddOutput", "points 1", 0, null, null)
        EntFireByHandle(redGoal, "AddOutput", "points 1", 0, null, null)
        SetScreenText("SUDDEN DEATH!", "255 255 255", 4, 3)
        SetChatText("SUDDEN DEATH! Next goal wins!", null)
    }
    else{
        // overtime state:
        // Teams are tied OR winning team doesn't have the ball
        g_overtime = true
        SetChatText("Overtime!", null)
    }

}

::On5SecRemain <- function()
{
    local ent = g_timerEntity
    if (ent){
        g_last5Sec = true
    }
}

::ifOvertime <- function()
{
    //DebugPrint("!!In overtime!!")
    local bluGoal = Entities.FindByName(null, "blue_goal")
    local redGoal = Entities.FindByName(null, "red_goal")
    local bluScore = g_teamScores[BLU_TEAM];
    local redScore = g_teamScores[RED_TEAM];
    local game_round_win = Entities.FindByClassname(null, "game_round_win");
    local carrier = g_ballState["currentCarrier"]
    local carrierTeam = null
    local gamerules = Entities.FindByClassname(null, "tf_gamerules")
    g_last5Sec = false
    if (carrier != null){
        carrierTeam = GetPropInt(carrier, "m_iTeamNum")
    }
    if (bluScore > redScore && carrierTeam == BLU_TEAM){
        EntFireByHandle(game_round_win, "SetTeam", "3", -1, null, null);
        EntFireByHandle(game_round_win, "RoundWin", "", -1, null, null);
        g_overtime = false
    }
    else if (redScore > bluScore && carrierTeam == RED_TEAM){
        EntFireByHandle(game_round_win, "SetTeam", "2", -1, null, null);
        EntFireByHandle(game_round_win, "RoundWin", "", -1, null, null);
        g_overtime = false
    }
    else if (bluScore != redScore){
     local pointdiff = abs(redScore - bluScore)
        if (g_pendingPoints[RED_TEAM] > pointdiff){
            //EntFireByHandle(bluGoal, "AddOutput", "points 1", 0, null, null)
            //SetPropInt(gamerules, "m_iWinningTeam", 2)
            //DebugPrint("RED team winning!")

        }
        else if (g_pendingPoints[BLU_TEAM] > pointdiff){
            //EntFireByHandle(redGoal, "AddOutput", "points 1", 0, null, null)
            //SetPropInt(gamerules, "m_iWinningTeam", 3)
            //DebugPrint("BLU team winning!")
        }
        else{
            local currentBluGoalPts = GetPropInt(bluGoal, "points")
            local currentRedGoalPts = GetPropInt(redGoal, "points")
            if (currentBluGoalPts != 0 || currentRedGoalPts != 0){

                EntFireByHandle(bluGoal, "AddOutput", "points 0", 0, null, null)
                EntFireByHandle(redGoal, "AddOutput", "points 0", 0, null, null)
            }
        }
    }


}

//------------------------------------------------------------------------------------------------------
//////////////////
// Think helpers
//////////////////
//------------------------------------------------------------------------------------------------------

::UpdateBallState <- function()
{
    if (!g_ballEntity){
        g_ballState["state"] = null
        g_ballState["lastState"] = null
        return
    }
    else{
        //Determine team color of the ball (trail color)
        local team = GetPropInt(g_ballEntity, "m_iTeamNum")
        local carrier = GetPropInt(g_ballEntity, "m_hCarrier")
        local carrierTeam = GetPropInt(carrier, "m_iTeamNum")
        g_ballState["lastState"] = g_ballState["state"]
        local collision = GetPropInt(g_ballEntity, "m_iCollisionCount")

        if (team == RED_TEAM){
            g_ballState["state"] = "red"
        }
        else if (team == BLU_TEAM){
            g_ballState["state"] = "blue"
        }
        else{
            g_ballState["state"] = "neutral"
        }

        // If the ball is currently loose, get the velocity from its entity
        SetBallPos()
    }
}

::SetBallPos <- function()
{
    local carrier = GetPropInt(g_ballEntity, "m_hCarrier")
    if (carrier != -1){
        return
    }
    else{
        local ballPos = GetPropVector(g_ballEntity, "m_vecOrigin")
        local ballVel = GetPropVector(g_ballEntity, "m_vecVelocity")
        local ballVelocity = g_ballEntity.GetAbsVelocity()
        local ballForce = GetPropVector(g_ballEntity, "m_vecForce")
        if (ballVel != g_ballState["velocity"]){
            g_ballState["velocity"] = ballVel
            g_ballState["position"] = ballPos
            g_ballState["time"] = Time()
        }
    }
}


::ThinkFunction <- function()
{
    if (!g_ballEntity){
        InitializeBall()
    }
    if (!g_goalEntities[RED_TEAM] || !g_goalEntities[BLU_TEAM]){
        DebugPrint("No goal entities found, trying again")
        InitializeGoalEnts()
    }
    if (!g_scriptEntity){
        DebugPrint("No script entity found, trying again")
        InitializeScriptEntity()
    }
    if (!g_timerEntity){
        DebugPrint("No timer entity found, trying again")
        InitializeTimer()
    }
    if (!g_hudEntity){
        DebugPrint("No HUD entity found, trying again")
        InitializeHUD()
    }
    if (g_zonesFound == false){
        InitTrigger()
    }
    if (g_overtime == true){
        ifOvertime()
    }
    if (g_teamManagers[RED_TEAM] == null || g_teamManagers[BLU_TEAM] == null){
        GetTeams()
    }
    /*if (g_biEntity == null || g_matEntity == null)
    {
        GetBallIndicator()
    }*/

    CheckLanding()
    UpdateBallState()
    //MoveBallIndicator()
    RefreshScreenText()
    return -1
}

// Function for testing ball bounce indicator hack

/*::MoveBallIndicator <- function()
{
    if (g_biEntity == null || g_ballEntity == null)
    {
        DebugPrint("Ball indicator or ball entity not found")
        return
    }

    local ballPos = g_ballState["position"]
    local iPos = Vector(1062, ballPos.y + 20, ballPos.z)
    //g_biEntity.AcceptInput("SetParent", "!activator", g_ballEntity, null)
    g_biEntity.SetAbsOrigin(iPos)
    local xDiff = abs(ballPos.x - iPos.x)
    local yDiff = abs(ballPos.y - iPos.y)
    local zDiff = abs(ballPos.z - iPos.z)
    local xDiffString = xDiff.tostring()
    local minScale = 0.0
    local maxScale = 2.0
    local maxDiff = 1000
    local scale = minScale + (maxScale - minScale) * clamp(xDiff / maxDiff, 0, 1)
    local mins = Vector(-scale, -scale, -scale)
    local maxs = Vector(scale, scale, scale)
    g_biEntity.SetSolid(2)
    g_biEntity.SetSize(mins, maxs)
    EntFireByHandle(g_matEntity, "SetMaterialVar", xDiffString, 0, null, null)


}*/

::clamp <- function(value, min, max)
{
    if (value < min) return min
    if (value > max) return max
    return value
}

::CheckLanding <- function()
{
    local player = null
    while (player = Entities.FindByClassname(player, "player")){
        local playerName = GetPlayerName(player)
        local playerIndex = player.entindex()
        local vel = player.GetAbsVelocity()
        local zVel = vel.z
        if (zVel == 0){
            local stateTables = [
                g_rocketJumpState,
                g_validExtenderSplash,
                g_validExtenderThrow,
                g_validExtenderAttempt,
                g_validZoneExtenderAttempt,
                g_validInstadetSplash,
                g_validInstadetExtenderAttempt,
                g_awardInstadetExtender
            ]
            foreach (table in stateTables){
                if (playerIndex in table){
                    delete table[playerIndex]
                    DebugPrint("[OnRocketJumpLanded] Deleted " + playerName + " from state table" + table)
                }
            }
        }
    }
}

::InitializePoints <- function()
{
    // Initialize points
    ::g_teamScores[RED_TEAM] = 0
    ::g_teamScores[BLU_TEAM] = 0
    ::g_pendingPoints[RED_TEAM] = 0
    ::g_pendingPoints[BLU_TEAM] = 0

}


::InitializeScriptEntity <- function()
{
    g_scriptEntity = Entities.FindByClassname(null, "logic_script")
    if (!g_scriptEntity){
        DebugPrint("No script entity found")
        return
    }
    DebugPrint("Found script entity at index: " + g_scriptEntity.entindex())
}

::InitializeTimer <- function()
{
    local timer = Entities.FindByClassname(null, "team_round_timer")
    if (!timer){
        DebugPrint("No timer found")
        return
    }
    DebugPrint("Found timer at index: " + timer.entindex())
    g_timerEntity = timer
    local tgScript = g_scriptEntity.GetName()
    EntityOutputs.AddOutput(timer, "OnFinished", tgScript, "CallScriptFunction", "OnGameEnd", 0, -1)
    EntityOutputs.AddOutput(timer, "On5SecRemain", tgScript, "CallScriptFunction", "On5SecRemain", 0, -1)

}

::InitializeBall <- function()
{
    g_ballEntity = Entities.FindByClassname(null, "passtime_ball")
    if (!g_ballEntity){
        return
    }
    DebugPrint("Found ball at index: " + g_ballEntity.entindex())
    //g_ballState["state"] = "neutral"
}

::InitializeGoalEnts <- function()
{
    local goal = null
    local goalCount = 0
    while (goal = Entities.FindByClassname(goal, "func_passtime_goal")){
        goalCount++
        local teamNum = GetPropInt(goal, "m_iTeamNum")
        if (teamNum == BLU_TEAM){
            g_goalEntities[RED_TEAM] = goal
            DebugPrint("Found RED goal at index: " + g_goalEntities[RED_TEAM].entindex())
            g_goalEntities[RED_TEAM].KeyValueFromString("points", "0")
        }
        else if (teamNum == RED_TEAM){
            g_goalEntities[BLU_TEAM] = goal
            DebugPrint("Found BLU goal at index: " + g_goalEntities[BLU_TEAM].entindex())
            g_goalEntities[BLU_TEAM].KeyValueFromString("points", "0")
        }
        else{
            DebugPrint("Unknown team number for goal entity: " + teamNum)
        }
    }
    if (!g_goalEntities[RED_TEAM]){
        DebugPrint("No RED goal found")
        return
    }
    if (!g_goalEntities[BLU_TEAM]){
        DebugPrint("No BLU goal found")
        return
    }

}

::InitializeHUD <- function()
{
    g_hudEntity = Entities.FindByClassname(null, "tf_logic_player_destruction")
    if (!g_hudEntity){
        DebugPrint("No HUD entity found")
        return
    }
    DebugPrint("Found HUD entity at index: " + g_hudEntity.entindex())
}

::InitializeThinkFunction <- function()
{
    if (!g_scriptEntity){
        DebugPrint("No script entity found")
        return
    }
    AddThinkToEnt(self, "ThinkFunction")
}

::InitializeConvars <- function()
{
    Convars.SetValue("tf_tournament_classlimit_scout", 0)
    Convars.SetValue("tf_tournament_classlimit_soldier", -1)
    Convars.SetValue("tf_tournament_classlimit_pyro", 0)
    Convars.SetValue("tf_tournament_classlimit_demoman", 0)
    Convars.SetValue("tf_tournament_classlimit_heavy", 0)
    Convars.SetValue("tf_tournament_classlimit_engineer", 0)
    Convars.SetValue("tf_tournament_classlimit_medic", 0)
    Convars.SetValue("tf_tournament_classlimit_sniper", 0)
    Convars.SetValue("tf_tournament_classlimit_spy", 0)
    Convars.SetValue("tf_passtime_ball_reset_time", 999999)
    Convars.SetValue("tf_passtime_scores_per_round", 99999)
    Convars.SetValue("tf_spawn_glows_duration", 999999)
    Convars.SetValue("tf_spec_xray", 1)
    Convars.SetValue("mp_winlimit", 2)
    Convars.SetValue("tf_playergib", 0)
    
    // TODO:
    // Commands still handled in map by point_servercommand:
    /*
    sm plugins unload soap_tf2dm
    sm plugins unload soap_tournament
    tftrue_whitelist_id 18135
    */
}

::GetBallIndicator <- function()
{
    g_biEntity = Entities.FindByName(null, "bi_rl")
    g_matEntity = Entities.FindByClassname(null, "material_modify_control")
    if (!g_biEntity){
        DebugPrint("No bi entity found")
        return
    }
    if (!g_matEntity){
        DebugPrint("No mat entity found")
        return
    }
}

::GetTeams <- function()
{
        local ent = null
        while ((ent = Entities.FindByClassname(ent, "tf_team")) != null) {
        local teamNum = GetPropInt(ent, "m_iTeamNum")
        if (teamNum == RED_TEAM)
        {
            g_teamManagers[RED_TEAM] = ent
            DebugPrint("Found RED team manager at index: " + g_teamManagers[RED_TEAM].entindex())
        }
        else if (teamNum == BLU_TEAM)
        {
            g_teamManagers[BLU_TEAM] = ent
            DebugPrint("Found BLU team manager at index: " + g_teamManagers[BLU_TEAM].entindex())
        }
        else
        {
            DebugPrint("Unknown team number for team manager entity: " + teamNum)
        }
        EnumerateTable(g_teamManagers)
}
}
::InitializeEntities <- function()
{
    InitializeBall()
    InitializeGoalEnts()
    InitializeHUD()
    InitializeScriptEntity()
}

::Initialize <- function()
{
    InitializePoints()
    InitializeEntities()
    InitializeThinkFunction()
    CreateScreenText()
}



::InitTrigger <- function()
{
    local zone1 = Entities.FindByName(null, "zone1")
    if (!zone1){
        g_zonesFound = false
    }
    else{
        g_zonesFound = true
        DebugPrint("Found zone1 at index: " + zone1.entindex())
    }
    local zone2 = Entities.FindByName(null, "zone2")
    local zone3 = Entities.FindByName(null, "zone3")
    local zone4 = Entities.FindByName(null, "zone4")
    local zone5 = Entities.FindByName(null, "zone5")
    local zone6 = Entities.FindByName(null, "zone6")
    local zone7 = Entities.FindByName(null, "zone7")
    local zone8 = Entities.FindByName(null, "zone8")
    local zone9 = Entities.FindByName(null, "zone9")
    local zone10 = Entities.FindByName(null, "zone10")
    local zone11 = Entities.FindByName(null, "zone11")
    local zone12 = Entities.FindByName(null, "zone12")
    local zone13 = Entities.FindByName(null, "zone13")
    local zone14 = Entities.FindByName(null, "zone14")
    local zone15 = Entities.FindByName(null, "zone15")
    local zone16 = Entities.FindByName(null, "zone16")
    local zone17 = Entities.FindByName(null, "zone17")
    //EntFire("zone1", "AddOutput", "OnStartTouch !self:RunScriptCode:OnSpecialTrigger(1, 1, 1)", 0, "!activator")
    //EntFire("zone1", "AddOutput", "OnEndTouch !self:RunScriptCode:OnSpecialTrigger(1, 1, 0)", 0, "!activator")
    EntityOutputs.AddOutput(zone1, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(1, 1)", 0, -1)
    EntityOutputs.AddOutput(zone1, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(1, 0)", 0, -1)
    EntityOutputs.AddOutput(zone2, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(2, 1)", 0, -1)
    EntityOutputs.AddOutput(zone2, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(2, 0)", 0, -1)
    EntityOutputs.AddOutput(zone3, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(3, 1)", 0, -1)
    EntityOutputs.AddOutput(zone3, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(3, 0)", 0, -1)
    EntityOutputs.AddOutput(zone4, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(4, 1)", 0, -1)
    EntityOutputs.AddOutput(zone4, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(4, 0)", 0, -1)
    EntityOutputs.AddOutput(zone5, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(5, 1)", 0, -1)
    EntityOutputs.AddOutput(zone5, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(5, 0)", 0, -1)
    EntityOutputs.AddOutput(zone6, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(6, 1)", 0, -1)
    EntityOutputs.AddOutput(zone6, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(6, 0)", 0, -1)
    EntityOutputs.AddOutput(zone7, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(7, 1)", 0, -1)
    EntityOutputs.AddOutput(zone7, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(7, 0)", 0, -1)
    EntityOutputs.AddOutput(zone8, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(8, 1)", 0, -1)
    EntityOutputs.AddOutput(zone8, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(8, 0)", 0, -1)
    EntityOutputs.AddOutput(zone9, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(9, 1)", 0, -1)
    EntityOutputs.AddOutput(zone9, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(9, 0)", 0, -1)
    EntityOutputs.AddOutput(zone10, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(10, 1)", 0, -1)
    EntityOutputs.AddOutput(zone10, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(10, 0)", 0, -1)
    EntityOutputs.AddOutput(zone11, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(11, 1)", 0, -1)
    EntityOutputs.AddOutput(zone11, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(11, 0)", 0, -1)
    EntityOutputs.AddOutput(zone12, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(12, 1)", 0, -1)
    EntityOutputs.AddOutput(zone12, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(12, 0)", 0, -1)
    EntityOutputs.AddOutput(zone13, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(13, 1)", 0, -1)
    EntityOutputs.AddOutput(zone13, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(13, 0)", 0, -1)
    EntityOutputs.AddOutput(zone14, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(14, 1)", 0, -1)
    EntityOutputs.AddOutput(zone14, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(14, 0)", 0, -1)
    EntityOutputs.AddOutput(zone15, "OnStartTouch", "!activator", "RunScriptCode", "OnBallFan(15)", 0, -1)
    EntityOutputs.AddOutput(zone16, "OnStartTouch", "!activator", "RunScriptCode", "OnBallFan(16)", 0, -1)
    EntityOutputs.AddOutput(zone17, "OnStartTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(17, 1)", 0, -1)
    EntityOutputs.AddOutput(zone17, "OnEndTouch", "!activator", "RunScriptCode", "OnSpecialTrigger(17, 0)", 0, -1)
}

::OnBallFan <- function(zone)
{
    local ent = activator
    g_ballFanned = true
}

::CheckEntityOwnership <- function(zone) {
    if (!(zone in g_zoneEntities)) {
        return false
    }

    // Get entities from the zone
    local zoneData = g_zoneEntities[zone]

    // Check if we have all required entities
    if (!("player" in zoneData) || !("passtime_ball" in zoneData)) {
        DebugPrint("[CheckEntityOwnership] FALSE: Missing required entities in zone " + zone)
        return false
    }

    // Get the first player in the zone
    local player = null
    foreach (entIndex, ent in zoneData["player"]) {
        player = ent
        break
    }

    if (!player) return false

    // Get the last ball carrier from global state
    local lastCarrier = g_ballState["lastCarrier"]
    if (!lastCarrier || !lastCarrier.IsValid()) return false

    // Check if the player matches the last carrier
    if (player != lastCarrier) {
        DebugPrint("[CheckEntityOwnership] FALSE: Player in zone doesn't match last ball carrier")
        return false
    }

    DebugPrint("[CheckEntityOwnership] All ownership checks passed!")
    return true
}

::CheckZoneComplete <- function(zoneId)
{
        if (!(zoneId in g_zoneEntities)) {
        return false
    }

    // Check if all required types are present in this zone
    foreach (reqType in g_requiredTypes) {
        if (!(reqType in g_zoneEntities[zoneId]) || g_zoneEntities[zoneId][reqType].len() == 0) {
            DebugPrint("[CheckZoneComplete] Zone " + zoneId + " is missing required type: " + reqType)
            return false
        }
    }
    EnumerateTable(g_zoneEntities[zoneId])
    DebugPrint ("[CheckZoneComplete] Zone " + zoneId + " is complete with all required types.")
    return true
}


::OnSpecialTrigger <- function(zone, enter) {
    local ent = activator
    if (!ent || !ent.IsValid())
        return

    local classname = ent.GetClassname()
    local entIndex = ent.entindex()

    // Initialize zone tracking if needed
    if (!(zone in g_zoneEntities)) {
        g_zoneEntities[zone] <- {}
    }

    // Initialize entity type tracking if needed
    if (!(classname in g_zoneEntities[zone])) {
        g_zoneEntities[zone][classname] <- {}
    }

    // Track entity entering/leaving zone
    if (enter == 1) {
        g_zoneEntities[zone][classname][entIndex] <- ent
        DebugPrint("[OnSpecialTrigger] " + classname + " " + entIndex + " entered zone " + zone)
    }

    else {
        // Handle entity leaving zone
        // Remove from zone tracking
        if (entIndex in g_zoneEntities[zone][classname]) {
            delete g_zoneEntities[zone][classname][entIndex]
        }
        DebugPrint("[OnSpecialTrigger] " + classname + " " + entIndex + " left zone " + zone)
    }
}

Initialize()