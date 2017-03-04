
-- Override tree pollution if not nil
tree_pollution = 0

-- Make all tiles work like desert for pollution
always_sand_absorb_rate = true

-- Efficency modules dont reduce net pollution (directly)
efficency_modules_increase_pollution = true

-- Pollution for solar to generate
solar_pollution = 0.03

-- Use more aggressive algorithm for creating new biter bases
create_expansion_bases = true
-- Dont start creating biter expansion bases for this time period after game start
expansion_start_delay = 60*60*30
-- Frequency to check for possible expansion locations in ticks.
-- The games update rate is 60 per second
expansion_check_frequency = 60 * 60 * 5
-- Chunks with a pollution greater than this are considered for expansion bases
expansion_pollution_threshold = 150
-- Limit number of bases to try to spawn in one go, when more possible locations are identified,
-- then the ones to attempt are picked at random.
-- The value used between min and max scales with evolution (rounded down).
min_expansion_limit = 1
max_expansion_limit = 10
-- How close to any player structure a new biter base chunk may be.
-- The value used between max and min scales with evolution.
min_expansion_player_distance = 48
max_expansion_player_distance = 128

-- Factor to multiply chunk pollution by to give the size of the new base.
expansion_size_factor = 200/7000
-- If true, sets map_settings.enemy_expansion.enabled = false
disable_vanilla_expansion = true



-- The intention here is to not pick the exact same frames that other mods do for scripting work
-- Work is further split across several ticks
-- (iterate chunks, pollution filter, ai filter, player filter, spawn bases)
expansion_check_offset = math.ceil(expansion_check_frequency / 2) + 234
