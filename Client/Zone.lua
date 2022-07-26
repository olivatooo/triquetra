Events.Subscribe("ApplyPoison", function (amount)
  if amount > 0 then
    PlaySFX("bleeding_effect.ogg")
  end
  UI:CallEvent("ApplyPoison", amount)
end)
