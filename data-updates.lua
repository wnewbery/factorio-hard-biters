require("config")
if tree_pollution ~= nil then
  for name, tree in pairs(data.raw.tree) do
    tree.emissions_per_tick = tree_pollution
  end
end
if always_sand_absorb_rate then
  local ageing = data.raw.tile["sand"].ageing
  for name, tile in pairs(data.raw.tile) do
    tile.ageing = ageing
  end
end
if efficency_modules_increase_pollution then
  -- Make efficency modules increase pollution a bit to counteract energy reduction
  -- Using efficency 3 will cause less pollution increase
  -- 3x efficency 1 exceeds 20% cap, then 600% pollution results in 120% net pollution
  data.raw.module["effectivity-module"  ].effect["pollution"] = {bonus = 3.0 }
  -- 2x efficency 2 reaches 20% cap, then 500% pollution takes that 20% back to 100%
  data.raw.module["effectivity-module-2"].effect["pollution"] = {bonus = 2.5}
  -- 2x efficency 3 exceeds 20% cap, then 400% pollution takes that 20% back to 100%
  -- Combined with speed/productivty will be a slight improvement in pollution
  data.raw.module["effectivity-module-3"].effect["pollution"] = {bonus = 2.0 }
end
if disable_vanilla_expansion then
  data.raw["map-settings"]["map-settings"].enemy_expansion.enabled = false
end
data.raw["solar-panel"]["solar-panel"].emissions_per_tick = solar_pollution
