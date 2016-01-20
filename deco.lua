-----------------
-- Decorations --
-----------------

-- The main decoration handler, through the game's decoration manager.


-- I like having different stone scattered about. Sandstone forms
--  in layers. Desert stone... doesn't exist, but let's assume it's
--  another sedementary rock and place it similarly.
minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})

local waterflow = 3
minetest.override_item("default:river_water_source", {liquid_range = waterflow})
minetest.override_item("default:river_water_flowing", {liquid_range = waterflow})
minetest.override_item("default:river_water_source", {is_ground_content = true})
minetest.override_item("default:river_water_flowing", {is_ground_content = true})

if false then
	minetest.override_item("default:river_water_source", {light_source = 14})
	minetest.override_item("default:river_water_flowing", {light_source = 14})
	minetest.override_item("default:water_source", {light_source = 14})
	minetest.override_item("default:water_flowing", {light_source = 14})
end

if false then
	local newnode = valc.clone_node("default:water_source")
	newnode.description = "Water"
	newnode.alpha = 0
	newnode.liquid_alternative_source = "valleys_c:water_source"
	newnode.liquid_alternative_flowing = "valleys_c:water_flowing"
	minetest.register_node("valleys_c:water_source", newnode)

	newnode = valc.clone_node("default:water_flowing")
	newnode.description = "Water"
	newnode.alpha = 0
	newnode.liquid_alternative_source = "valleys_c:water_source"
	newnode.liquid_alternative_flowing = "valleys_c:water_flowing"
	minetest.register_node("valleys_c:water_flowing", newnode)
end


-- Some sand with rocks for the river beds.
--  This drops small rocks as well.
if false then
local newnode = valc.clone_node("default:sand")
newnode.description = "Sand and rocks"
newnode.tiles = {"vmg_sand_with_rocks.png"}
newnode.drop = {max_items=2, items={{items={"valleys_c:small_rocks"}, rarity=1}, {items={"default:sand"}, rarity=1}}}
minetest.register_node("valleys_c:sand_with_rocks", newnode)
end

minetest.register_node("valleys_c:sand_with_rocks", {
	description = "Sand and rocks",
	tiles = {"vmg_sand_with_rocks.png"},
	groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = default.node_sound_sand_defaults(),
	drop = {max_items=2, items={{items={"valleys_c:small_rocks"}, rarity=1}, {items={"default:sand"}, rarity=1}}},
})

if valc.glow then
	minetest.register_node("valleys_c:glowing_sand", {
		description = "Sand with luminescent bacteria",
		tiles = {"default_sand.png"},
		groups = {crumbly = 3, falling_node = 1, sand = 1},
		light_source = 3,
		drop = "default:sand",
		sounds = default.node_sound_sand_defaults(),
	})
end


function table.contains_substring(t, s)
	if type(s) ~= "string" then
		return nil
	end

  for key, value in pairs(t) do
    if type(value) == 'string' and s:find(value) then
			if key then
				return key
			else
				return true
			end
    end
  end
  return false
end


-- Copy all the decorations except the ones I don't like.
--  This is currently used to remove the default trees.
local bad_deco = {"apple_tree", "pine_tree", "jungle_tree", }
local decos = {}
for id, deco_table in pairs(minetest.registered_decorations) do
	if type(deco_table.schematic) ~= "string" or not table.contains_substring(bad_deco, deco_table.schematic) then
		table.insert(decos, deco_table)
	end
end


-- Create and initialize a table for a schematic.
function valc.schematic_array(width, height, depth)
	-- Dimensions of data array.
	local s = {size={x=width, y=height, z=depth}}
	s.data = {}

	for z = 0,depth-1 do
		for y = 0,height-1 do
			for x = 0,width-1 do
				local i = z*width*height + y*width + x + 1
				s.data[i] = {}
				s.data[i].name = "air"
				s.data[i].param1 = 000
			end
		end
	end

	s.yslice_prob = {}

	return s
end


-- Clear all decorations, so I can place the new trees.
minetest.clear_registered_decorations()

-- A list of all schematics, for re-use.
valc.schematics = {}


-- Specific decoration code.
if valc.houses then
	dofile(valc.path.."/deco_houses.lua")
end

dofile(valc.path.."/deco_coral.lua")
dofile(valc.path.."/deco_dirt.lua")
dofile(valc.path.."/deco_trees.lua")
dofile(valc.path.."/deco_plants.lua")
dofile(valc.path.."/deco_rocks.lua")
dofile(valc.path.."/deco_caves.lua")
dofile(valc.path.."/deco_ferns.lua")
dofile(valc.path.."/deco_ferns_tree.lua")
dofile(valc.path.."/deco_water.lua")


	-- biomes = {"sandstone_grassland", "glacier", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp",},


-- Re-register the good decorations.
-- This has to be done after registering the trees or
--  the trees spawn on top of grass.  /shrug
for _, i in pairs(decos) do
	minetest.register_decoration(i)
end

