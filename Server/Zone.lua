OriginalRadius = 10000
Radius = 10000

local ZoneOrigin = Vector(0,0,0)
local TheZone = Trigger(ZoneOrigin, Rotator(), Vector(Radius), TriggerType.Sphere, true, Color(1, 0, 0))

function Poison(character)
  if character and character:IsValid() and character:GetType() == "Character" and character:GetHealth() > 0 then
    local player = character:GetPlayer()
    if player then
      Events.CallRemote("ApplyPoison", player, 100)
    end
    local poison = Timer.SetInterval(function(_character)
        _character:ApplyDamage(math.floor(33 - (Radius-500)/500))
        if _character:GetHealth() <= 0 then
          Unpoison(character)
        end
    end, 3500, character)
    character:SetValue("Poison", poison)
    Timer.Bind(poison, character)
  end
end

function Unpoison(character)
  if character and character:IsValid() and character:GetType() == "Character" and character:GetHealth() > 0 then
    local player = character:GetPlayer()
    if player then
      Events.CallRemote("ApplyPoison", player, 0)
    end
    local poison = character:GetValue("Poison")
    if poison then
      Timer.ClearInterval(poison)
    end
  end
end


TheZone:Subscribe("BeginOverlap", function(self, entity)
  Unpoison(entity)
end)

TheZone:Subscribe("EndOverlap", function(self, entity)
  Poison(entity)
end)

-- ZoneEffect = StaticMesh(
--   ZoneOrigin,
--   Rotator(),
--   "nanos-world::SM_Sphere"
-- )
-- ZoneEffect:SetCollision(CollisionType.NoCollision)

-- ZoneEffect:SetMaterialColorParameter("Tint", Color(0, 1, 0))
-- ZoneEffect:SetMaterial("nanos-world::M_NanosWireframe")

-- This is the round time in seconds, maps should not be larger so 2min should be enough
RoundTime = 12000
Timer.SetInterval(function ()
  TheZone:SetExtent(Vector(Radius))

  -- Zone Effect this is a default sphere size
  -- BROKEN FOR NOW
  -- ZoneEffect:SetScale(Vector(Radius/50))
  if Radius > 1 then
    Radius = Radius - 1
  end
end, 1)

function ResetRadius()
  Radius = OriginalRadius
end
