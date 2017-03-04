require "config"
-- inspect = require "third_party.inspect.inspect" --TODO: Should really add it to the path


--function log(str)
--  str = game.tick .. ": " .. str .. "\n"
--  game.write_file("enhanced_biter_ai.txt", str, true)
--end
function lerp(a, b, t)
  return a + (b - a) * t
end
function lerpi(a, b, t)
  return math.floor(lerp(a, b, t))
end


function init_globals()
    global.expansion_state = global.expansion_state or {
        version = 1,
        step = 0,
        temp = 0
    }
end

-- TODO: This all needs to be stored per-surface to work correctly with multiple surfaces
-- Phase 1, get chunks into a lua array
function expansion_1_chunks(surface)
  local chunks = {}
  for chunk in surface.get_chunks() do
    table.insert(chunks, {chunk["x"] * 32, chunk["y"] * 32})
  end
  global.expansion_state.temp = chunks
  global.expansion_state.step = 1 
end
-- Phase 2, filter by pollution
function expansion_2_pollution(surface)
  local chunks = global.expansion_state.temp
  local filtered = {}
  for k,v in pairs(chunks) do
    if surface.get_pollution(v) > expansion_pollution_threshold then
      table.insert(filtered, v)
    end
  end
  global.expansion_state.temp = filtered
  global.expansion_state.step = 2
end
--Phase 3, filter by spawners
function expansion_3_spawners(surface)
  local chunks = global.expansion_state.temp
  local filtered = {}
  for k,v in pairs(chunks) do
    local x = v[1]
    local y = v[2]
    local area = {{x - 32, y - 32}, {x + 63, y + 63}}
    if surface.count_entities_filtered{area=area, force="enemy", type="unit-spawner"} == 0 then
      table.insert(filtered, v)
    end
  end
  global.expansion_state.temp = filtered
  global.expansion_state.step = 3
end
--Phase 4, filter by player
function expansion_4_player(surface)
  local chunks = global.expansion_state.temp
  local filtered = {}
  local min_distance = lerpi(max_expansion_player_distance, min_expansion_player_distance, game.evolution_factor)
  for k,v in pairs(chunks) do
    local x = v[1]
    local y = v[2]
    local area = {{x - min_distance, y - min_distance}, {x + 32 + min_distance, y + 32 + min_distance}}
    if surface.count_entities_filtered{area=area, force="player"} == 0 then
      table.insert(filtered, v)
    end
  end
  global.expansion_state.temp = filtered
  global.expansion_state.step = 4
end
--Phase 5, check for space (trees, water)
function expansion_5_space(surface)
  local chunks = global.expansion_state.temp
  local filtered = {}
  for k,v in pairs(chunks) do
    local x = v[1] + 16
    local y = v[2] + 16
    if surface.find_non_colliding_position("spitter-spawner", {x,y}, 16, 2) ~= nil then
      table.insert(filtered, v)
    end
  end
  global.expansion_state.temp = filtered
  global.expansion_state.step = 5
end

--Phase 6, spawn
function expansion_6_spawn(surface)
  local locations = global.expansion_state.temp
  local filtered = {}
  local count = 0
  local expansion_limit = lerpi(min_expansion_limit, max_expansion_limit, game.evolution_factor)
  -- log("possible locations: " .. #locations)
  while count < expansion_limit and #locations > 0 do
    count = count + 1
    local i = math.random(#locations)
    local location = {locations[i][1] + 16, locations[i][2] + 16}
    local size = expansion_size_fn(surface.get_pollution(location))
    table.insert(filtered, locations[i])
    table.remove(locations, i)
    -- log("build base: " .. location[1] .. "," .. location[2])
    surface.build_enemy_base(location, math.ceil(size))
  end
  
  global.expansion_state.temp = filtered
  global.expansion_state.step = 6
end

-- Check if a base was actually spawned
function expansion_check_spawn_results(surface)
  local locations = global.expansion_state.temp
  for k,v in pairs(locations) do
    local x = v[1]
    local y = v[2]
    local area = {{x, y}, {x + 32, y + 32}}
    --if surface.count_entities_filtered{area=area, force="enemy", type="unit-spawner"} > 0 then
    --  log("spawned at " .. x .. "," .. y)
    --else
    --  log("spawn failed at " .. x .. "," .. y)
    --end
  end
end

script.on_init(init_globals)
script.on_configuration_changed(init_globals)

script.on_event(defines.events.on_tick, function()
  if game.tick >= expansion_start_delay then
    local tick = (game.tick % expansion_check_frequency) - expansion_check_offset
    --TODO: Multiple surfaces, needs seperate state sets
    local surface = game.surfaces[1]
    if create_expansion_bases then
        local step = global.expansion_state.step
        if (tick ==  0) then
          --expansion_check_spawn_results(surface)
          expansion_1_chunks(surface)
        elseif (tick ==  5 and step == 1) then expansion_2_pollution(surface)
        elseif (tick == 10 and step == 2) then expansion_3_spawners(surface)
        elseif (tick == 15 and step == 3) then expansion_4_player(surface)
        elseif (tick == 20 and step == 4) then expansion_5_space(surface)
        elseif (tick == 25 and step == 5) then expansion_6_spawn(surface)
        end
    end
  end
end)

