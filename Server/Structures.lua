function TeamStructure(placement)
  local j = StaticMesh(placement + Vector(-150.0,-554.09997558594,164.39999389648), Rotator(0.0, 180.0, 0.0),"nanos-world::SM_Cube_VR_03")
  j:SetScale(Vector(1.6000000238419,1.6000000238419,1.6000000238419))
  j:SetValue("Jail", true)
  j = StaticMesh(placement + Vector(-148.39999389648,1048.8000488281,158.5), Rotator(0.0, 178.59375, 0.0),"nanos-world::SM_Cube_VR_03")
  j:SetScale(Vector(1.7000000476837,1.7000000476837,1.7000000476837))
  j:SetValue("Jail", true)

  j = StaticMesh(placement + Vector(1147.8000488281,301.79998779297,186.80000305176), Rotator(0.0, 178.59375, 0.0),"nanos-world::SM_Cube_VR_03")
  j:SetScale(Vector(1.6000000238419,1.6000000238419,1.6000000238419))
  j:SetValue("Jail", true)


  j = StaticMesh(placement + Vector(-141.69999694824,1054.0,-4.5999999046326), Rotator(0.0, 149.0625, 358.59375),"nanos-world::SM_ConstructionFence")
  j:SetScale(Vector(4.9000000953674,4.9000000953674,4.9000000953674))
  j:SetValue("Jail", true)

  j = StaticMesh(placement + Vector(-152.30000305176,-545.29998779297,-21.799999237061), Rotator(0.0, 270.0, 0.0),"nanos-world::SM_ConstructionFence")
  j:SetScale(Vector(5.0999999046326,5.0999999046326,5.0999999046326))
  j:SetValue("Jail", true)

  j = StaticMesh(placement + Vector(1141.6999511719,269.10000610352,-16.299999237061), Rotator(0.0, 33.75, 0.0),"nanos-world::SM_ConstructionFence")
  j:SetScale(Vector(5.0,5.0,5.0))
  j:SetValue("Jail", true)
end

function SpawnMap(tp1 , tp2)
  min_map_size = 500
  max_map_size = 1000
  for _=min_map_size, min_map_size +math.random(max_map_size) do
      local x = (tp1.X + tp2.X)/2 + math.random( -5000, 5000 )
      local y = (tp1.Y + tp2.Y)/2 + math.random( -5000, 5000 )
      local z = math.random(-25, 100)
      local rx = 0
      local ry = 0
      local rz = 0

      local sx = 1.1
      local sy = 1.1
      local sz = 1.3


      if math.random(100) > 60 then
        rx = 222.5
      end

      if math.random(100) > 60 then
        ry = 222.5
      end

      if math.random(100) > 60 then
        rz = 222.5
      end


      local ifx = 10
      while math.random(100) > ifx do
        sx = sx ^ 1.61803398
        if sx > 15 then
          sx = 10
        end



        ifx = ifx + 10
      end

      ifx = 20
      while math.random(100) > ifx do
        sy = sy ^ 1.61803398
        if sy > 15 then
          sy = 10
        end
        ifx = ifx + 10
      end

      ifx = 10
      while math.random(100) > ifx do
        sz = sz ^ 1.61803398
        if sz > 15 then
          sz = 10
        end
        ifx = ifx + 10
      end

      local mesh = StaticMesh(Vector(x, y, z), Rotator(rx, ry, rz), "nanos-world::SM_Cube")
      mesh:SetScale(Vector(sx, sy, sz))
      mesh:SetMaterialColorParameter("Tint", Color.Random())
    end
end
