Package.RequirePackage("nanos-world-weapons")
Package.RequirePackage("rounds")

Package.Require("Sh_Funcs.lua")

Package.Require("Structures.lua")
Package.Require("Store.lua")
Package.Require("Score.lua")
Package.Require("Zone.lua")

INIT_ROUNDS({
  ROUND_TYPE = "TEAMS",
  ROUND_TEAMS = {"PASSED_TEAMS", "LOBBYSTART_GENERATION", { {}, {} }, true},
  ROUND_START_CONDITION = {"PLAYERS_NB", 2},
  ROUND_END_CONDITION = {"REMAINING_TEAMS", 1},
  SPAWN_POSSESS = {"CHARACTER"},
  SPAWNING = {"TEAM_SPAWNS", { { {Vector(-5000,-5000,0), Rotator()} }, { {Vector(5000,5000,0), Rotator()} } }, "LOBBYSTART_SPAWN"},
  WAITING_ACTION = {"SPECTATE_REMAINING_PLAYERS", false},
  PLAYER_OUT_CONDITION = {"DEATH"},
  PLAYER_OUT_ACTION = {"WAITING"},
  ROUNDS_INTERVAL_ms = 10000,
  MAX_PLAYERS = 6,
  CAN_JOIN_DURING_ROUND = false,
  LOBBY_CONFIG = {20000},
  ROUNDS_DEBUG = false,
})

-- List of teams
-- Teams are list of players
function InitializeTeams()

  for team_index = 1, 2 do
    Teams[team_index] = {}
    Teams[team_index].Points = 0
    Teams[team_index].Budget = 9999
    Teams[team_index].Players = {}
    Teams[team_index].Budgeted = false
    Teams[team_index].Color = Color.Random()
  end

end


function ResetGame()
  Teams = {}
  InitializeTeams()

  Events.BroadcastRemote("ClearPoints")
end
ResetGame()

function CreateScoreByTeams()
  local queue = {}
  for index,v in pairs(TEAMS_PLAYERS) do
    for _,k in pairs(v) do
      local score = k:GetValue("Score")
      if score then
        table.insert(queue, {index, k:GetName() .. " - " .. tostring(score)})
      end
    end
  end
  --Package.Log(queue)
  return queue
end


function Post()
  Events.BroadcastRemote("SetRoundStatus", "Post")

  Events.BroadcastRemote("ClearUI")

  ClearMap()

  for k,v in pairs(PLAYERS_JOINED) do
    -- TODO: Implement matchmaking system
    -- v:Kick("thanks for playing")

    -- Resets the game
    v:SetValue("Score", 0)
  end

  Events.BroadcastRemote("SetScore", JSON.stringify((CreateScoreByTeams())))

  Events.BroadcastRemote("ShowScore")

  ResetGame()
end


function ClearMap()
  for _,v in pairs(Weapon.GetAll()) do
    v:Destroy()
  end
end

Events.Subscribe("RoundPlayerSpawned", function(ply)
  local team_index = ply:GetValue("PlayerTeam")
  local char = ply:GetControlledCharacter()

  if IsValid(char) then
    -- Give a default weapon
    local makarov = NanosWorldWeapons.Makarov(Vector(0,0,1000000), Rotator())
    makarov:SetDamage(11)
    makarov:SetCadence(0.1)
    char:SetTeam(team_index)
    char:SetFallDamageTaken(0)


    -- Set team and team color
    local color = Teams[team_index].Color
    char:SetMaterialColorParameter("Tint", color)
    char:SetValue("Team", team_index, true)

    char:SetHealth(333)
    char:SetViewMode(ViewMode.FPS)
    char:SetCameraMode(CameraMode.FPSOnly)

    --print(char, makarov)
    char:PickUp(makarov)
    --print(char:GetPicked())

    -- Give a strong melee
    char:SetPunchDamage(66)

    -- Takes more headshot damage
    char:SetDamageMultiplier("head", 5)
    char:SetDamageMultiplier("neck_01", 5)
  end
end)

function ClearPoints()
  for i = 1, 3 do
    Events.BroadcastRemote("TeamRevive", i)
    Events.BroadcastRemote("EnemyRevive", i)
  end
end


function OnGoing()
  Events.BroadcastRemote("SetRoundStatus", "FIGHT!")
  Events.BroadcastRemote("OnGoing")
end
Events.Subscribe("RoundStart", OnGoing)

function LobbyEnding()
  Events.BroadcastRemote("CanPlayerBuy", false)
  -- Destroy team structure
  for _,k in pairs(StaticMesh.GetAll()) do
    if k:GetValue("Jail") then
      k:Destroy()
    end
  end
end
Events.Subscribe("LobbyEnding", LobbyEnding)


function Intermission()
  Events.BroadcastRemote("SetRoundStatus", "Intermission")
  local WinnerTeam = 1
  for _,v in pairs(Character.GetPairs()) do
    if v:GetHealth() > 0 then
      WinnerTeam = v:GetTeam()
    end
  end
  Teams[WinnerTeam].Points = Teams[WinnerTeam].Points + 1
  Events.BroadcastRemote("RoundWinnerIs", WinnerTeam)
  Events.BroadcastRemote("TeamRoundPoints", Teams[1].Points, Teams[2].Points)

  -- Show player queue
  Events.BroadcastRemote("ShowQueue")
  Events.BroadcastRemote("WaitingForOtherPlayers", table_count(PLAYERS_JOINED))

  ClearMap()

  if (Teams[WinnerTeam].Points >= 3 or not RoundStartCondition()) then
    Post()
  end
end
Events.Subscribe("RoundEnding", Intermission)


function GenerateTeamBudget(team)
  -- One time budget-
  if not Teams[team].Budgeted then
    Teams[team].Budgeted = true
    local budget = 9999
    Teams[team].Budget = budget
    for _,v in ipairs(TEAMS_PLAYERS[team]) do
      --Package.Log(Teams[team].Budget)
      v:SetValue("Money", budget, true)
      Events.CallRemote("SetMoney", v, budget)
    end
  end
end

-- Clean the map
-- Respawn Everyone
function Prepare()
  -- Reset Zone Radius
  ResetRadius()
  Events.BroadcastRemote("SetRoundStatus", "Prepare")
  Events.BroadcastRemote("Prepare")
  Events.BroadcastRemote("ClearUI")

  TeamStructure(ROUNDS_CONFIG.SPAWNING[2][1][1][1])
  GenerateTeamBudget(1)
  TeamStructure(ROUNDS_CONFIG.SPAWNING[2][2][1][1])
  GenerateTeamBudget(2)
  Timer.SetTimeout(function()
    Events.BroadcastRemote("CanPlayerBuy", true)
    ClearPoints()
  end, 2000)

  for team_index = 1, 2 do
    Teams[team_index].Players = TEAMS_PLAYERS[team_index]
  end

  -- Set Random Time
  Events.BroadcastRemote("SetTime", math.random(24))

  Events.BroadcastRemote("SetQueue", JSON.stringify((CreateQueueFromTeams())))

  Events.BroadcastRemote("Announce", "Hold B to Buy", "neutral_neon")
end
Events.Subscribe("LobbyStarted", Prepare)

Events.Subscribe("ROUND_PASS_TEAMS", function()
  local passed_tbl = {}
  for i = 1, 2 do
    if Teams[i].Players[1] then
      table.insert(passed_tbl, Teams[i].Players)
    else
      return
    end
  end

  local players_not_in_teams = {}
  for k, v in pairs(PLAYERS_JOINED) do
    local in_team

    for i2, v2 in ipairs(passed_tbl) do
      for i3, v3 in ipairs(v2) do
        if v == v3 then
          in_team = true
          break
        end
      end
    end

    if not in_team then
      table.insert(players_not_in_teams, v)
    end
  end

  for i, v in ipairs(players_not_in_teams) do
      local insert_in_team
      local smaller_count
      for i2, v2 in ipairs(passed_tbl) do
          local count = table_count(v2)
          if (not smaller_count or smaller_count > count) then
              insert_in_team = i2
              smaller_count = count
          end
      end

      if insert_in_team then
          v:SetValue("Money", 9999, true)
          Events.CallRemote("SetMoney", v, 9999)
          table.insert(passed_tbl[insert_in_team], v)
      end
  end


  TEAMS_FOR_THIS_ROUND = passed_tbl
end)


function GetAnotherTeam(team)
  if team == 1 then
    return 2
  else
    return 1
  end
end

-- TODO: Switch to clientside
Events.Subscribe("RoundPlayerOutDeath", function(self, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
  -- Give a point to team that killed
  if instigator and instigator:GetType() == "Player" then
    local c = instigator:GetControlledCharacter()
    if c then
      local team = c:GetTeam()
      for _,v in pairs(Teams[team].Players) do
        Events.CallRemote("EnemyDied", v, table_count(TEAMS_PLAYERS[GetAnotherTeam(team)]) - 1)
      end
      for _,v in pairs(Teams[GetAnotherTeam(team)].Players) do
        Events.CallRemote("TeamDied", v, table_count(TEAMS_PLAYERS[GetAnotherTeam(team)]) - 1)
      end
    end
  end
end)

Player.Subscribe("Destroy", function(ply)
  for k, v in pairs(Teams) do
    for i2, v2 in ipairs(v.Players) do
      if v2 == ply then
        table.remove(Teams[k].Players, i2)
        break
      end
    end
  end
end)


function CreateQueueFromTeams()
  local queue = {}
  for index,v in pairs(TEAMS_PLAYERS) do
    for _,k in pairs(v) do
      table.insert(queue, {index, k:GetName()})
    end
  end
  return queue
end