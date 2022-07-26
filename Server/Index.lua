Package.RequirePackage("nanos-world-weapons")
Package.Require("Structures.lua")
Package.Require("Store.lua")
Package.Require("Score.lua")
Package.Require("Zone.lua")

-- List of teams
-- Teams are list of players
function InitializeTeam(team_index, start_location)
  Teams[team_index] = {}
  Teams[team_index].Points = 0
  Teams[team_index].SpawnLocation = start_location
  Teams[team_index].Budget = 9999
  Teams[team_index].Players = {}
  Teams[team_index].Kills = 0
  Teams[team_index].Budgeted = false
  Teams[team_index].AlivePlayers = 0
  Teams[team_index].Color = Color.Random()
end


MatchStatus = {}
MatchStatus["WaitingForOtherPlayers"] = 0
MatchStatus["Prepare"] = 1
MatchStatus["OnGoing"] = 2
MatchStatus["Post"] = 3
MatchStatus["Intermission"] = 4
MatchStatus.Debug = false
MatchStatus.OrderedTeams = false
TeamSize = 3


function ResetGame()
  MatchStatus.OrderedTeams = false
  Round = 0
  Teams = {}
  TeamSize = 3
  InitializeTeam(1, Vector(-5000,-5000,0))
  InitializeTeam(2, Vector(5000,5000, 0))
  -- List of spectators
  Spectators = {}

  -- Actual Match Status
  Timeout = 9999999
  Status =  MatchStatus.WaitingForOtherPlayers
  Events.BroadcastRemote("ClearPoints")
end
ResetGame()


-- TODO: Check in database if player is allowed to connect
Server.Subscribe("PlayerConnect", function(IP, player_account_ID, player_name, player_steam_ID) end)

Player.Subscribe("Destroy", function(self)

  local team = self:GetValue("Team")

  for k,v in pairs(Teams[team].Players) do
    Package.Log(k)
    Package.Log(v)
  end

  local char = self:GetControlledCharacter()
  if char then
    char:Destroy()
  end
  if team then
    if Teams[team] then
      Teams[team].Players[self] = nil
      Package.Log("Player disconnected thus removed from team player list")
      if #Teams[team].Players == 0 then
        UpdateMatchStatus(MatchStatus.Post)
      end
    end
  end


  for k,v in pairs(Teams[team].Players) do
    Package.Log(k)
    Package.Log(v)
  end
end)

function DecreaseTimer()
  Timeout = Timeout - 1
  return Timeout <= 0
end


function UpdateMatchStatus(status)
  Package.Log("New Match Status: " .. status)
  if status == MatchStatus.WaitingForOtherPlayers then
    Status = MatchStatus.WaitingForOtherPlayers
    Timeout = 9999999

    -- Show player queue
    Events.BroadcastRemote("ShowQueue")

  elseif status == MatchStatus.Prepare then
    Status = MatchStatus.Prepare
    Timeout = 20
    Prepare()
  elseif status == MatchStatus.OnGoing then
    Status = MatchStatus.OnGoing
    Timeout = 300
    OnGoing()
  elseif status == MatchStatus.Intermission then
    Status = MatchStatus.Intermission
    Timeout = 10
    Intermission()
  elseif status == MatchStatus.Post then
    Status = MatchStatus.Post
    Timeout = 30
    Post()
  end
end

function CreateScoreByTeams()
  local queue = {}
  for index,v in pairs(Teams) do
    for _,k in pairs(v.Players) do
      local score = k:GetValue("Score")
      if score then
        table.insert(queue, {index, k:GetName() .. " - " .. tostring(score)})
      end
    end
  end
  Package.Log(queue)
  return queue
end


function Post()
  Events.BroadcastRemote("SetRoundStatus", "Post")
  for k,v in pairs(Player.GetAll()) do
    -- TODO: Implement matchmaking system
    -- v:Kick("thanks for playing")
    --
    ClearMap()

    Events.BroadcastRemote("ClearUI")
    Events.BroadcastRemote("ShowScore")
    Events.BroadcastRemote("SetScore", JSON.stringify((CreateScoreByTeams())))

    -- Resets the game
    v:SetValue("Score", 0)
  end
  Timer.SetTimeout(function()
    ResetGame()
  end, 30000)
end


function ClearMap()
  for _,v in pairs(Character.GetAll()) do
    v:Destroy()
  end
  for _,v in pairs(Weapon.GetAll()) do
    v:Destroy()
  end
end


function CreateTriquetaCharacter(team_index)
  -- This character receives more head damage
  -- This character have more life for bigger combats
  local char = Character(Teams[team_index].SpawnLocation, Rotator(), "nanos-world::SK_Mannequin")

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

  Timer.SetTimeout(function()
    char:SetHealth(333)
  end, 2000)
  char:SetViewMode(ViewMode.FPS)
  char:SetCameraMode(CameraMode.FPSOnly)
  Timer.SetTimeout(function()
    char:PickUp(makarov)
  end, 2000)

  -- Give a strong melee
  char:SetPunchDamage(66)

  -- Takes more headshot damage
  char:SetDamageMultiplier("head", 5)
  char:SetDamageMultiplier("neck_01", 5)

  return char
end

function ClearPoints()
  for i = 1, 3 do
    Events.BroadcastRemote("TeamRevive", i)
    Events.BroadcastRemote("EnemyRevive", i)
  end
end

function PrepareTeam(team_index)
  -- SPAWN TEAM STRUCTURE
  TeamStructure(Teams[team_index].SpawnLocation)
  -- SPAWN CHARACTERS
  -- ALLOW STORE
  --
  Teams[team_index].AlivePlayers = 0
  for _,v in pairs(Teams[team_index].Players) do
    if v and v:IsValid() then
      local char = CreateTriquetaCharacter(team_index)
      v:Possess(char)
      v:SetValue("Spectators", {})
      v:SetValue("Team", team_index)
      ListenForRoundEnd(char)
      Teams[team_index].AlivePlayers = Teams[team_index].AlivePlayers + 1
    end
  end
end


function OnGoing()
  Events.BroadcastRemote("SetRoundStatus", "FIGHT!")
  Events.BroadcastRemote("OnGoing")
  Events.BroadcastRemote("CanPlayerBuy", false)
  -- Destroy team structure
  for _,k in pairs(StaticMesh.GetAll()) do
    if k:GetValue("Jail") then
      k:Destroy()
    end
  end
end


function Intermission()
  -- TODO: Put this in another place
  Teams[1].AlivePlayers = #Teams[1].Players
  Teams[2].AlivePlayers = #Teams[2].Players

  Events.BroadcastRemote("SetRoundStatus", "Intermission")
  local WinnerTeam = 1
  for _,v in pairs(Character.GetAll()) do
    if v:GetHealth() > 0 then
      WinnerTeam = v:GetTeam()
    end
  end
  Teams[WinnerTeam].Points = Teams[WinnerTeam].Points + 1
  Events.BroadcastRemote("RoundWinnerIs", WinnerTeam)
  Events.BroadcastRemote("TeamRoundPoints", Teams[1].Points, Teams[2].Points)
end


function GenerateTeamBudget(team)
  -- One time budget
  -- local budget = (Round*666) + (Teams[team].Kills * 333) + (Teams[team].Points * 111)
  if not Teams[team].Budgeted then
    Teams[team].Budgeted = true
    local budget = 9999
    Teams[team].Budget = budget
    for _,v in ipairs(Teams[team].Players) do
      Package.Log(Teams[team].Budget)
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

  Round = Round + 1
  ClearMap()
  PrepareTeam(1)
  GenerateTeamBudget(1)
  PrepareTeam(2)
  GenerateTeamBudget(2)
  Timer.SetTimeout(function()
    Events.BroadcastRemote("CanPlayerBuy", true)
    ClearPoints()
  end, 2000)

  -- Set Random Time
  Events.BroadcastRemote("SetTime", math.random(24))
end


function SpectateAliveTeammate(player)
  local team = player:GetValue("Team") or 1
  for _, v in ipairs(Teams[team].Players) do
    if v:IsValid() then
      local teammate = v:GetControlledCharacter()
      if teammate:IsValid() and teammate:GetHealth() > 0 then

        local specs = v:GetValue("Spectators")
        if specs then
          table.insert(specs, player)
          player:Spectate(v, 1000)
        end
        return
      end
    end
  end
end


function GetAnotherTeam(team)
  if team == 1 then
    return 2
  else
    return 1
  end
end

function ListenForRoundEnd(char)
  char:Subscribe("Death", function(self, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator, causer)
    -- Give a point to team that killed
    if instigator and instigator:GetType() == "Player" then
      local c = instigator:GetControlledCharacter()
      if c then
        local team = c:GetTeam()
        Teams[team].Kills = Teams[team].Kills + 1
        for _,v in pairs(Teams[team].Players) do
          Events.CallRemote("EnemyDied", v, Teams[GetAnotherTeam(team)].AlivePlayers)
        end
        for _,v in pairs(Teams[GetAnotherTeam(team)].Players) do
          Events.CallRemote("TeamDied", v, Teams[GetAnotherTeam(team)].AlivePlayers)
        end
      end
    end

    local team = 1
    if self and self:IsValid() then
      team = self:GetTeam()
      Teams[team].AlivePlayers = Teams[team].AlivePlayers - 1
    end

    if Teams[team].AlivePlayers == 0 then
      UpdateMatchStatus(MatchStatus.Intermission)

    else
      Timer.SetTimeout(function(_char)
        local player = _char:GetPlayer()
        if player and player:IsValid() then
          -- Get all the spectators from this player
          local specs = player:GetValue("Spectators")
          -- Send all spectators to another player
          if specs then
            for _,v in pairs(specs) do
              SpectateAliveTeammate(v)
            end
          end
          SpectateAliveTeammate(player)
        end
        _char:Destroy()
      end, 2500, self)
    end
  end)
end


function CreateQueueFromTeams()
  local queue = {}
  for index,v in pairs(Teams) do
    for _,k in pairs(v.Players) do
      table.insert(queue, {index, k:GetName()})
    end
  end
  return queue
end

function AssignPlayerToTeam(player, team_index)
  player:SetValue("Team", team_index , true)
  Events.CallRemote("SetTeam", player, team_index)
  table.insert(Teams[team_index].Players, player)
end

function RegisterPlayer(player)
  if #Teams[1].Players < TeamSize then
    AssignPlayerToTeam(player, 1)
  elseif #Teams[2].Players < TeamSize then
    AssignPlayerToTeam(player, 2)
  else
    player:SetValue("Team", 3 , true)
    Events.CallRemote("SetTeam", player, 3)
    table.insert(Spectators, player)
  end
  Timer.SetTimeout(function()
    Events.BroadcastRemote("SetQueue", JSON.stringify((CreateQueueFromTeams())))
  end, 1000)
end

-- If someone disconnects, remove him from the queue
-- And put him in some team
function MoveSpecToPlayer()
  if #Spectators > 0 then
    local player = Spectators[1]
    table.remove(Spectators, 1)
    RegisterPlayer(player)
  end
end

function UnregisterPlayer(player)
  for _,v in pairs(Teams) do
    for i,k in ipairs(v.Players) do
      if k == player then
        table.remove(v.Players, i)
        MoveSpecToPlayer()
        break
      end
    end
  end
  for i,k in ipairs(Spectators) do
    if k == player then
      table.remove(Spectators, i)
      break
    end
  end
end


-- When the player connects we need to register him
-- Team 1
-- Team 2
-- Spectators
Player.Subscribe("Ready", function(self)
  if #Player.GetAll() == 1 then
    UpdateMatchStatus(MatchStatus.WaitingForOtherPlayers)
  end
  RegisterPlayer(self)
end)


-- When the player disconnects we need to unregister him
Player.Subscribe("Destroy", function(self)
  UnregisterPlayer(self)
end)


function WaitingForOtherPlayers()
  -- Get all players in server and distribute to teams
  if MatchStatus.OrderedTeams == false then
    MatchStatus.OrderedTeams = true
    for _,v in pairs(Player.GetAll()) do
      UnregisterPlayer(v)
    end
    for _,v in pairs(Player.GetAll()) do
      RegisterPlayer(v)
    end
  end

  Package.Log("Team 1 with :" .. #Teams[1].Players .. " Team 2 with : " .. #Teams[2].Players .. " Timeout: "  .. Timeout) 
  Events.BroadcastRemote("WaitingForOtherPlayers", #Player.GetAll())
  Events.BroadcastRemote("ShowQueue")

  if #Teams[1].Players == TeamSize and #Teams[2].Players == TeamSize then
    UpdateMatchStatus(MatchStatus.Prepare)
  elseif MatchStatus.Debug == true then
    UpdateMatchStatus(MatchStatus.Prepare)
  end
end


Timer.SetInterval(function()
  local time = DecreaseTimer()

  ---
  -- WAITING FOR OTHER PLAYERS
  ---
  if Status == MatchStatus.WaitingForOtherPlayers then
    WaitingForOtherPlayers()

    if time then
      -- Failed to connect
      UpdateMatchStatus(MatchStatus.Post)
    end

  ---
  -- IF END PREPARE THEN START THE MATCH
  -- MATCH ONLY ENDS WHEN A TEAM DIES SO TIMEOUT IS 99999
  ---
  elseif time and Status == MatchStatus.Prepare then
    Timeout = 99999
    UpdateMatchStatus(MatchStatus.OnGoing)

  ---
  --  IF IS IN INTERMISSION AND SOME TEAM SCORES 3 POINTS
  --  UPDATE TO POST MATCH BC SOMEONE WON
  --
  --  IF NO ONE WINS YET SO GO BACK TO PREPARE
  ---
  elseif time and Status == MatchStatus.Intermission then
    if Teams[1].Points == 3 or Teams[2].Points == 3 then
      Package.Log("some team scored 3 points")
      UpdateMatchStatus(MatchStatus.Post)
    else
      UpdateMatchStatus(MatchStatus.Prepare)
    end
  ---
  --  POST TIME SEND EVERYONE BACK TO LOBBY
  ---
  elseif time and Status == MatchStatus.Post then
    UpdateMatchStatus(MatchStatus.WaitingForOtherPlayers)
  end


  if Status == MatchStatus.Prepare then
    Package.Log("Prepare: " .. tostring(Timeout))
    Events.BroadcastRemote("SetRoundStatus", "Prepare: " .. tostring(Timeout))

    if Timeout == 20 then
      Events.BroadcastRemote("Announce", "Hold B to Buy", "neutral_neon")
    end
  end
end, 1000)


Package.Subscribe("Load", function()
  for _,v in pairs(Player.GetAll()) do
    RegisterPlayer(v)
  end
end)


Server.Subscribe("Console", function(my_input)
	if (my_input == "p") then
		for k, p in pairs(Server.GetPackages(true)) do
			Server.ReloadPackage(p)
		end
	end
	if (my_input == "post") then
      UpdateMatchStatus(MatchStatus.Post)
	end
	if (my_input == "ongoing") then
      UpdateMatchStatus(MatchStatus.OnGoing)
	end
	if (my_input == "prepare") then
      UpdateMatchStatus(MatchStatus.Prepare)
	end
	if (my_input == "wfot") then
      UpdateMatchStatus(MatchStatus.WaitingForOtherPlayers)
	end
	if (my_input == "intermission") then
      UpdateMatchStatus(MatchStatus.Intermission)
	end
end)
