SoundIntro = nil
Events.Subscribe("WaitingForOtherPlayers", function(number_of_players)
  if SoundIntro == nil or SoundIntro:IsValid() == false or SoundIntro:IsPlaying() == false then
    SoundIntro = PlaySFX("into_the_fire.ogg")
  end
  UI:CallEvent("SetRoundStatus", "WaitingForOtherPlayers: " .. tostring(number_of_players) .. "/6")
end)

Events.Subscribe("SetRoundStatus", function(notice)
  if SoundIntro and SoundIntro:IsValid() and SoundIntro:IsPlaying() then
    SoundIntro:FadeOut(1, 0, true)
  end
  UI:CallEvent("SetRoundStatus", notice)
end)

Events.Subscribe("Announce", function(notice, mood)
  UI:CallEvent("Announce", notice, mood)
end)

Events.Subscribe("TeamRoundPoints", function(team_1_points, team_2_points)
  if MyTeam == 1 then
    for k=1, team_1_points do
      UI:CallEvent("TeamPoint", k)
    end
    for k=1, team_2_points do
      UI:CallEvent("EnemyPoint", k)
    end
  else
    for k=1, team_1_points do
      UI:CallEvent("EnemyPoint", k)
    end
    for k=1, team_2_points do
      UI:CallEvent("TeamPoint", k)
    end
  end
end)

--
-- Handle Buy Menu
--
BuyMenu = false
BuyMenuVisibility = true
Input.Register("BuyMenu", "B")
Input.Bind("BuyMenu", InputEvent.Pressed, function()
  if BuyMenu then
    if BuyMenuVisibility == true then
      -- -- Closes the Buy Menu
      -- Client.SetMouseEnabled(false)
      -- UI:CallEvent("HideStore")
        BuyMenuVisibility = false
      else
      -- -- Open the Buy Menu
      -- Client.SetMouseEnabled(true)
      -- UI:CallEvent("ShowStore")
        BuyMenuVisibility = true
    end
    ShowBuyMenu(BuyMenuVisibility)
  end
end)

function ShowBuyMenu(can_buy)
  Client.SetMouseEnabled(can_buy)
  Client.SetInputEnabled(not can_buy)
  BuyMenuVisibility = can_buy
  if can_buy then
    UI:CallEvent("ShowStore")
  else
    UI:CallEvent("HideStore")
  end
end

-- Subscribes for Releasing the key
-- Input.Bind("BuyMenu", InputEvent.Released, function()
-- end)

Events.Subscribe("CanPlayerBuy", function(can)
  BuyMenu = can
  if can == false then
    PlaySFX("mogus.ogg")
  end
  ShowBuyMenu(can)
end)

Events.Subscribe("HideStore", function()
  UI:CallEvent("HideStore")
end)

Events.Subscribe("ShowStore", function()
  UI:CallEvent("ShowStore")
end)


Events.Subscribe("RoundWinnerIs", function(WinnerTeam)
  if WinnerTeam == MyTeam then
    UI:CallEvent("Announce", "Round Won", "positive_neon")
  else
    UI:CallEvent("Announce", "Round Lost", "negative_neon")
  end
end)


Events.Subscribe("OnGoing", function()
    UI:CallEvent("Announce", "START!", "neutral_neon")
end)

Character.Subscribe("HealthChanged", function(char, old_health, new_health)
  if (new_health < old_health) then
    Sound(Vector(), "nanos-world::A_HitTaken_Feedback", true)
  end

  UI:CallEvent("SetHealth", new_health)
end)

-- Sets on character an event to update his grabbing weapon (to show ammo on UI)
Character.Subscribe("PickUp", function(char, object)
  if (object:GetType() == "Weapon") then

    UI:CallEvent("ShowAmmo")
    UI:CallEvent("SetActualAmmo", object:GetAmmoClip())
    UI:CallEvent("SetAmmoBag",object:GetAmmoBag())

    -- Subscribes on the weapon when the Ammo changes
    object:Subscribe("AmmoClipChanged", OnAmmoClipChanged)

    object:Subscribe("AmmoBag", OnAmmoBagChanged)
  end
end)

-- Sets on character an event to remove the ammo ui when he drops it's weapon
Character.Subscribe("Drop", function(char, object)
  -- Unsubscribes from events
  if (object:GetType() == "Weapon") then
    UI:CallEvent("HideAmmo")
    object:Unsubscribe("AmmoClipChanged", OnAmmoClipChanged)
    object:Unsubscribe("AmmoBagChanged", OnAmmoBagChanged)
  end

end)


-- Callback when Weapon Ammo Clip changes
function OnAmmoClipChanged(weapon, old_ammo_clip, new_ammo_clip)
  UI:CallEvent("SetActualAmmo", weapon:GetAmmoClip())
end


-- Callback when Weapon Ammo Bag changes
function OnAmmoBagChanged(weapon, old_ammo_bag, new_ammo_bag)
  UI:CallEvent("SetAmmoBag", weapon:GetAmmoBag())
end

