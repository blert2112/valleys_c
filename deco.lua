-----------------
-- Decorations --
-----------------

-- The main decoration handler, through the game's decoration manager.


-- I like having different stone scattered about. Sandstone forms
--  in layers. Desert stone... doesn't exist, but let's assume it's
--  another sedementary rock and place it similarly.
minetest.register_ore({ore_type="sheet", ore="default:sandstone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=4130293965, octaves=5, persist=0.60}, random_factor=1.0})
minetest.register_ore({ore_type="sheet", ore="default:desert_stone", wherein="default:stone", clust_num_ores=250, clust_scarcity=60, clust_size=10, y_min=-1000, y_max=31000, noise_threshhold=0.1, noise_params={offset=0, scale=1, spread={x=256, y=256, z=256}, seed=163281090, octaves=5, persist=0.60}, random_factor=1.0})


-- Some sand with rocks for the river beds.
--  This drops small rocks as well.
do
	local newnode = valc.clone_node("default:sand")
	newnode.tiles = {"vmg_sand_with_rocks.png"}
	newnode.drop = {max_items=2, items={{items={"valleys_c:small_rocks"}, rarity=1}, {items={"default:sand"}, rarity=1}}}
	minetest.register_node("valleys_c:sand_with_rocks", newnode)
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

	for x = 0,width-1 do
		for y = 0,height-1 do
			for z = 0,depth-1 do
				local i = x*width*height + y*width + z + 1
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
dofile(valc.path.."/deco_trees.lua")
dofile(valc.path.."/deco_plants.lua")
dofile(valc.path.."/deco_rocks.lua")
dofile(valc.path.."/deco_caves.lua")
dofile(valc.path.."/deco_ferns.lua")


	-- biomes = {"sandstone_grassland", "glacier", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp",},


-- Re-register the good decorations.
-- This has to be done after registering the trees or
--  the trees spawn on top of grass.  /shrug
for _, i in pairs(decos) do
	minetest.register_decoration(i)
end

