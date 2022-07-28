Package.RequirePackage("rounds")

Package.Require("Sh_Funcs.lua")

MyTeam = 1
Money = 0
UIDelay = 1000
World.SpawnDefaultSun()

UI = WebUI("UI", "file:///UI/Index.html")

function PlaySFX(sound_asset, volume, pitch)
	local sound = Sound(Vector(), "package///triquetra/Client/SFX/" .. sound_asset , true, true, SoundType.SFX, volume or 1, pitch or 1)
  return sound
end

Package.Require("GUI.lua")
Package.Require("Zone.lua")


Player.Subscribe("ValueChange", function(ply, key, value)
  if ply == Client.GetLocalPlayer() then
    if key == "PlayerTeam" then
      if value then
        MyTeam = value
      end
    end
  end
end)

Events.Subscribe("SpawnSound", function(location, sound_asset, is_2D, volume, pitch)
	Sound(location, sound_asset, is_2D, true, SoundType.SFX, volume or 1, pitch or 1)
end)

UI:Subscribe("BuyItem", function(item, level)
  Events.CallRemote("BuyItem", item, level)
end)


Events.Subscribe("SetMoney", function(money)
  Money = money
  Timer.SetTimeout(function()
    UI:CallEvent("SetMoney", Money)
  end, UIDelay)
  PlaySFX("money_in.ogg")
end)


Events.Subscribe("ConfirmBuyItem", function(item, level)
  UI:CallEvent("ConfirmBuyItem", item, level)
  PlaySFX("pick_up_weapon.ogg")
end)


Events.Subscribe("SetQueue", function(queue)
  Timer.SetTimeout(function()
    UI:CallEvent("SetQueue", queue)
  end, UIDelay)
end)


Events.Subscribe("HideQueue", function()
  Timer.SetTimeout(function()
    UI:CallEvent("HideQueue")
  end, UIDelay)
end)

Events.Subscribe("ShowQueue", function()
  Timer.SetTimeout(function()
    UI:CallEvent("ShowQueue")
  end, UIDelay)
end)


Events.Subscribe("ShowScore", function()
  Timer.SetTimeout(function()
    UI:CallEvent("ShowScore")
  end, UIDelay)
end)


Events.Subscribe("SetScore", function(queue)
  Timer.SetTimeout(function()
    UI:CallEvent("SetScore", queue)
  end, UIDelay)
end)


Events.Subscribe("HideScore", function()
  Timer.SetTimeout(function()
    UI:CallEvent("HideScore")
  end, UIDelay)
end)

Events.Subscribe("ClearUI", function()
  Timer.SetTimeout(function()
    UI:CallEvent("ClearUI")
  end, UIDelay)
end)

Events.Subscribe("EnemyDied", function(index)
  UI:CallEvent("EnemyDied", index)
  PlaySFX("shield_broken.ogg")
end)

Events.Subscribe("EnemyRevive", function(index)
  UI:CallEvent("EnemyRevive", index)
end)

Events.Subscribe("TeamRevive", function(index)
  UI:CallEvent("TeamRevive", index)
end)

Events.Subscribe("TeamDied", function(index)
  UI:CallEvent("TeamDied", index)
  PlaySFX("flesh_hit.ogg")
end)

Events.Subscribe("ClearPoints", function()
  UI:CallEvent("ClearPoints")
end)

Events.Subscribe("SetTime", function(hours)
  World.SetTime(hours, 0)
  World.SetSunSpeed(1)
end)

Events.Subscribe("Prepare", function()
  Timer.SetTimeout(function()
    -- UI:SetFocus()
    UI:BringToFront()
    UI:CallEvent("ResetStore")
  end, UIDelay)
end)