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