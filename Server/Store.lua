function HealthShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local health = char:GetHealth()
    health = health + math.floor(health*0.33)
    char:SetHealth(health)
  end
end

function SpeedShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local speed = char:GetSpeedMultiplier()
    speed = speed + 1
    char:SetSpeedMultiplier(speed)
  end
end

function SizeShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local scale = char:GetScale()
    scale = Vector((scale.X * 0.9), (scale.Y * 0.9), (scale.Z * 0.9))
    --Package.Log(scale)
    char:SetScale(scale)
  end
end

function GravityShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local gravity = char:GetGravityScale()
    gravity = gravity - math.floor(gravity*0.33)
    char:SetGravityScale(gravity)
    char:SetImpactDamageTaken(0)
  end
end

function JumpShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local jump_z = char:GetJumpZVelocity()
    jump_z = jump_z + math.floor(jump_z*0.66)
    char:SetJumpZVelocity(jump_z)
  end
end

function HelmetShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local damage_multiplier = char:GetDamageMultiplier("head")
    damage_multiplier = damage_multiplier - 1

    char:SetDamageMultiplier("head", damage_multiplier)
    char:SetDamageMultiplier("neck_01", damage_multiplier)
    char:AddStaticMeshAttached("hat", "nanos-world::SM_TopHat", "head_socket", Vector(-15.25, 0, 15), Rotator(0, -90, -5))
  end
end


function KevlarShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local damage_multiplier = char:GetDamageMultiplier("spine_01")
    damage_multiplier = damage_multiplier - 0.1

    char:SetDamageMultiplier("spine_01", damage_multiplier)
    char:SetDamageMultiplier("spine_02", damage_multiplier)
    char:SetDamageMultiplier("spine_03", damage_multiplier)
    char:AddSkeletalMeshAttached("shirt", "nanos-world::SK_Shirt")
  end
end


function PunchShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local punch_damage = char:GetPunchDamage()
    punch_damage = punch_damage + 100
    char:SetPunchDamage(punch_damage)
  end
end


function SpawnHFG(location, rotation)
    local weapon = Weapon(location or Vector(), rotation or Rotator(), "nanos-world::SK_DC15S")

    weapon:SetAmmoSettings(33, 0)
    weapon:SetDamage(0)
    weapon:SetSpread(30)
    weapon:SetSightTransform(Vector(-6, 0, -5), Rotator(0, 0, 0))
    weapon:SetLeftHandTransform(Vector(19, 0, 5), Rotator(0, 60, 90))
    weapon:SetRightHandOffset(Vector(-7, 0, -1))
    weapon:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
    weapon:SetCadence(2)
    weapon:SetSoundDry("nanos-world::A_Pistol_Dry")
    weapon:SetSoundZooming("nanos-world::A_AimZoom")
    weapon:SetSoundAim("nanos-world::A_Rattle")
    weapon:SetSoundFire("nanos-world::A_ShotgunBlast_Shot")
    weapon:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
    weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
    weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
    weapon:SetUsageSettings(true, false)

    weapon:Subscribe("Fire", function(self, character)
      local control_rotation = character:GetControlRotation()
      local forward_vector = control_rotation:GetForwardVector()
      local spawn_location = self:GetLocation() + forward_vector * 200

      local grenade = Grenade(spawn_location, Rotator(), "nanos-world::SM_Grenade_G67", "nanos-world::P_Explosion_Dirt", "nanos-world::A_Explosion_Large")
      grenade:SetScale(Vector(3, 3, 3))

      local trail_particle = Particle(spawn_location, Rotator(), "nanos-world::P_Ribbon", false, true)
      trail_particle:SetParameterColor("Color", Color.RandomPalette())
      trail_particle:SetParameterFloat("LifeTime", 1)
      trail_particle:SetParameterFloat("SpawnRate", 30)
      trail_particle:SetParameterFloat("Width", 1)
      trail_particle:AttachTo(grenade)
      grenade:SetValue("Particle", trail_particle)
      grenade:SetDamage(333, 33, 200, 1000, 1)

      grenade:Subscribe("Hit", function(self, intensity)
        self:Explode()
      end)

      grenade:Subscribe("Destroy", function(self, intensity)
        self:GetValue("Particle"):SetLifeSpan(1)
      end)

      grenade:AddImpulse(forward_vector * 3000, true)
    end)

    return weapon
end

function GrenadeLauncherShop(player)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local weapon = SpawnHFG(Vector(0,0,-10000), Rotator())

    local pick = char:GetPicked()
    if IsValid(pick) then
      pick:Destroy()
    end
    char:PickUp(weapon)
  end
end


--
-- parameters must be:
-- weapon name
-- optional: damage
-- optional: spread
--
function SpawnWeapon(player, level, param)
  local char = player:GetControlledCharacter()
  if IsValid(char) then
    local weapon = param[1]
    weapon = NanosWorldWeapons[weapon](Vector(0, 0, -10000), Rotator())
    local damage = param[2] or weapon:GetDamage()
    damage = damage + math.floor(damage*0.11*level)
    weapon:SetDamage(damage)

    local spread = param[3] or weapon:GetSpread()
    weapon:SetSpread(spread)

    local pick = char:GetPicked()
    if IsValid(pick) then
      pick:Destroy()
    end

    char:PickUp(weapon)
  end
end


SHOP = {
  helmet = {
    value = 333,
    func = HelmetShop
  },
  kevlar = {
    value = 333,
    func = KevlarShop
  },
  health= {
    value = 333,
    func = HealthShop
  },
  speed = {
    value = 333,
    func = SpeedShop
  },
  size = {
    value = 333,
    func = SizeShop
  },
  gravity = {
    value = 333,
    func = GravityShop
  },
  jump = {
    value = 333,
    func = JumpShop
  },
  ak47 = {
    value = 3333,
    func = SpawnWeapon,
    param = {"AK47", 33, 120}
  },
  ar4 = {
    value = 3000,
    func = SpawnWeapon,
    param = {"AR4", 18, 1}
  },
  glock = {
    value = 333,
    func = SpawnWeapon,
    param = {"Glock"}
  },
  de = {
    value = 666,
    func = SpawnWeapon,
    param = {"DesertEagle", 66, 666}
  },
  shotgun = {
    value = 999,
    func = SpawnWeapon,
    param = {"Moss500"}
  },
  smg = {
    value = 666,
    func = SpawnWeapon,
    param = {"AP5", 16, 333}
  },
  awp = {
    value = 6666,
    func = SpawnWeapon,
    param = {"AWP", 333}
  },
  launcher = {
    value = 6666,
    func = GrenadeLauncherShop,
  },
};

Events.Subscribe("BuyItem", function (player, item, level)
  local money = player:GetValue("Money") or 0
  if money >= SHOP[item].value then
    money = money - SHOP[item].value
    player:SetValue("Money", money, true)
    Events.CallRemote("SetMoney", player, money)
    local func = SHOP[item].func
    func(player, level, SHOP[item].param)
    Events.CallRemote("ConfirmBuyItem", player, item, level)
  end
end)

