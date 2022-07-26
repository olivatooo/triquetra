Character.Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator, causer)

  -- Clamps the damage to Health
  local health = self:GetHealth()
  local true_damage = health < damage and health or damage

  if instigator and instigator:IsValid() and instigator:GetType() == "Player" then
    local score = instigator:GetValue("Score")
    if score then
      score = score + true_damage
      instigator:SetValue("Score", score)
    else
      instigator:SetValue("Score", true_damage)
    end
  end
end)
