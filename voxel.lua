----------------------
-- Voxel Manip Loop --
----------------------

-- This is only used to handle cases the decoration manager can't,
--  such as water plants and cave decorations.


-- Define perlin noises used in this mapgen by default
valc.noises = {}

-- Noise 13 : Clayey dirt noise						2D
valc.noises[13] = {offset = 0, scale = 1, seed = 2835, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}

-- Noise 14 : Silty dirt noise						2D
valc.noises[14] = {offset = 0, scale = 1, seed = 6674, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}

-- Noise 15 : Sandy dirt noise						2D
valc.noises[15] = {offset = 0, scale = 1, seed = 6940, spread = {x = 256, y = 256, z = 256}, octaves = 5, persist = 0.5, lacunarity = 4}

-- Noise 16 : Beaches							2D
valc.noises[16] = {offset = 2, scale = 8, seed = 2349, spread = {x = 256, y = 256, z = 256}, octaves = 3, persist = 0.5, lacunarity = 2}

-- Noise 21 : Water plants							2D
valc.noises[21] = {offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = 33, octaves = 3, persist = 0.7, lacunarity = 2.0}

-- Noise 22 : Cave blend							2D
valc.noises[22] = {offset = 0.0, scale = 0.1, spread = {x = 8, y = 8, z = 8}, seed = 4023, octaves = 2, persist = 1.0, lacunarity = 2.0}

-- Noise 23 : Cave noise							2D
valc.noises[23] = {offset = 0.0, scale = 1.0, spread = {x = 400, y = 400, z = 400}, seed = 903, octaves = 3, persist = 0.5, lacunarity = 2.0}

-- function to get noisemaps
function valc.noisemap(i, minp, chulens)
	local obj = minetest.get_perlin_map(valc.noises[i], chulens)
	if minp.z then
		return obj:get3dMap_flat(minp)
	else
		return obj:get2dMap_flat(minp)
	end
end

-- useful function to convert a 3D pos to 2D
function pos2d(pos)
	if type(pos) == "number" then
		return {x = pos, y = pos}
	elseif pos.z then
		return {x = pos.x, y = pos.z}
	else
		return {x = pos.x, y = pos.y}
	end
end

-- Check if a chunk contains a huge cave.
-- This sucks. Use gennotify when possible.
local function survey(data, area, maxp, minp, lava, water, air)
	local index_3d
	local space = 0
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index_3d = area:index(x, maxp.y, z)
			for y = maxp.y, minp.y, -1 do
				index_3d = index_3d - area.ystride
				-- The mapgen won't place lava or water near a huge cave.
				if data[index_3d] == lava or data[index_3d] == water then
					return false
				elseif data[index_3d] == air then
					space = space + 1
				end

				-- This shortcut may skip lava or water, causing a false
				-- positive, but it can save a lot of time.
				-- This is an extremely poor way to check, but there aren't
				-- any good ways, and all the others take more cpu time.
				if space > 20000 then
					return true
				end
			end
		end
	end

	return false
end

local mapgen_times = {
	liquid_lighting = {},
	loops = {},
	make_chunk = {},
	noisemaps = {},
	preparation = {},
	writing = {},
}


-- Define content IDs
-- A content ID is a number that represents a node in the core of Minetest.
-- Every nodename has its ID.
-- The VoxelManipulator uses content IDs instead of nodenames.

local node = {}

local nodes = {
	-- Ground nodes
	{"stone", "default:stone"},
	{"dirt", "default:dirt"},
	{"dirt_with_grass", "default:dirt_with_grass"},
	{"dirt_with_dry_grass", "default:dirt_with_dry_grass"},
	{"dirt_with_snow", "default:dirt_with_snow"},
	{"sand", "default:sand"},
	{"sandstone", "default:sandstone"},
	{"desert_sand", "default:desert_sand"},
	{"gravel", "default:gravel"},
	{"desertstone", "default:desert_stone"},
	{"river_water_source", "default:river_water_source"},
	{"water_source", "default:water_source"},
	{"lava", "default:lava_source"},

	{"sand_with_rocks", "valleys_c:sand_with_rocks"},
	{"glowing_sand", "valleys_c:glowing_sand"},
	{"fungal_stone", "valleys_c:glowing_fungal_stone"},
	{"stalactite", "valleys_c:stalactite"},
	{"stalactite_slimy", "valleys_c:stalactite_slimy"},
	{"stalactite_mossy", "valleys_c:stalactite_mossy"},
	{"stalagmite", "valleys_c:stalagmite"},
	{"stalagmite_slimy", "valleys_c:stalagmite_slimy"},
	{"stalagmite_mossy", "valleys_c:stalagmite_mossy"},
	{"mushroom_cap_giant", "valleys_c:giant_mushroom_cap"},
	{"mushroom_cap_huge", "valleys_c:huge_mushroom_cap"},
	{"mushroom_stem", "valleys_c:giant_mushroom_stem"},
	{"mushroom_red", "flowers:mushroom_red"},
	{"mushroom_brown", "flowers:mushroom_brown"},
	{"waterlily", "flowers:waterlily"},
	{"brain_coral", "valleys_c:brain_coral"},
	{"dragon_eye", "valleys_c:dragon_eye"},
	{"pillar_coral", "valleys_c:pillar_coral"},
	{"staghorn_coral", "valleys_c:staghorn_coral"},

	{"dirt_clay", "valleys_c:dirt_clayey"},
	{"lawn_clay", "valleys_c:dirt_clayey_with_grass"},
	{"dry_clay", "valleys_c:dirt_clayey_with_dry_grass"},
	{"snow_clay", "valleys_c:dirt_clayey_with_snow"},
	{"dirt_silt", "valleys_c:dirt_silty"},
	{"lawn_silt", "valleys_c:dirt_silty_with_grass"},
	{"dry_silt", "valleys_c:dirt_silty_with_dry_grass"},
	{"snow_silt", "valleys_c:dirt_silty_with_snow"},
	{"dirt_sand", "valleys_c:dirt_sandy"},
	{"lawn_sand", "valleys_c:dirt_sandy_with_grass"},
	{"dry_sand", "valleys_c:dirt_sandy_with_dry_grass"},
	{"snow_sand", "valleys_c:dirt_sandy_with_snow"},
	{"silt", "valleys_c:silt"},
	{"clay", "valleys_c:red_clay"},

	-- Air and Ignore
	{"air", "air"},
	{"ignore", "ignore"},

	{"ice", "default:ice"},
	{"thinice", "valleys_c:thin_ice"},
	--{"crystal", "valleys_c:glow_crystal"},
	--node["gem"]1 = minetest.get_content_id("valleys_c:glow_gem")
	--node["gem"]2 = minetest.get_content_id("valleys_c:glow_gem_2")
	--node["gem"]3 = minetest.get_content_id("valleys_c:glow_gem_3")
	--node["gem"]4 = minetest.get_content_id("valleys_c:glow_gem_4")
	--node["gem"]5 = minetest.get_content_id("valleys_c:glow_gem_5")
	--node["saltgem"]1 = minetest.get_content_id("valleys_c:salt_gem")
	--node["saltgem"]2 = minetest.get_content_id("valleys_c:salt_gem_2")
	--node["saltgem"]3 = minetest.get_content_id("valleys_c:salt_gem_3")
	--node["saltgem"]4 = minetest.get_content_id("valleys_c:salt_gem_4")
	--node["saltgem"]5 = minetest.get_content_id("valleys_c:salt_gem_5")
	--node["spike"]1 = minetest.get_content_id("valleys_c:spike")
	--node["spike"]2 = minetest.get_content_id("valleys_c:spike_2")
	--node["spike"]3 = minetest.get_content_id("valleys_c:spike_3")
	--node["spike"]4 = minetest.get_content_id("valleys_c:spike_4")
	--node["spike"]5 = minetest.get_content_id("valleys_c:spike_5")
	{"moss", "valleys_c:stone_with_moss"},
	{"lichen", "valleys_c:stone_with_lichen"},
	{"algae", "valleys_c:stone_with_algae"},
	{"salt", "valleys_c:stone_with_salt"},
	{"hcobble", "valleys_c:hot_cobble"},
	{"gobsidian", "valleys_c:glow_obsidian"},
	{"gobsidian2", "valleys_c:glow_obsidian_2"},
	{"coalblock", "default:coalblock"},
	{"obsidian", "default:obsidian"},
	--{"desand", "default:desert_sand"},
	--{"coaldust", "valleys_c:coal_dust"},
	--{"fungus", "valleys_c:fungus"},
	--{"mycena", "valleys_c:mycena"},
	--{"worm", "valleys_c:glow_worm"},
	{"icicle_up", "valleys_c:icicle_up"},
	{"icicle_down", "valleys_c:icicle_down"},
	{"flame", "valleys_c:constant_flame"},
	--{"fountain", "valleys_c:s_fountain"},
	--{"fortress", "valleys_c:s_fortress"},

	{"fungal_tree_fruit", "valleys_c:fungal_tree_fruit"},
}

for _, i in pairs(nodes) do
	node[i[1]] = minetest.get_content_id(i[2])
end

node["fungal_tree_leaves"] = {}
for _, name in pairs(valc.fungal_tree_leaves) do
	node["fungal_tree_leaves"][#node["fungal_tree_leaves"]+1] = minetest.get_content_id(name)
end

local soil_translate = {}
soil_translate["clay_over"] = {
	dirt = node["clay"],
	lawn = node["clay"],
	dry = node["clay"],
	snow = node["clay"],
}
soil_translate["clay_under"] = {
	dirt = node["dirt_clay"],
	lawn = node["lawn_clay"],
	dry = node["dry_clay"],
	snow = node["snow_clay"],
}
soil_translate["silt_over"] = {
	dirt = node["silt"],
	lawn = node["silt"],
	dry = node["silt"],
	snow = node["silt"],
}
soil_translate["silt_under"] = {
	dirt = node["dirt_silt"],
	lawn = node["lawn_silt"],
	dry = node["dry_silt"],
	snow = node["snow_silt"],
}
soil_translate["sand"] = {
	dirt = node["dirt_sand"],
	lawn = node["lawn_sand"],
	dry = node["dry_sand"],
	snow = node["snow_sand"],
}
soil_translate["dirt"] = {
	dirt = node["dirt"],
	lawn = node["dirt_with_grass"],
	dry = node["dirt_with_dry_grass"],
	snow = node["dirt_with_snow"],
}

local water_lily_biomes = {"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest", "desertstone_grassland", }
local coral_biomes = {"desert_ocean", "savanna_ocean", "rainforest_ocean", }

local clay_threshold = 1
local silt_threshold = 1
local sand_threshold = 0.75
local dirt_threshold = 0.75

--local clay_threshold = vmg.define("clay_threshold", 1)
--local silt_threshold = vmg.define("silt_threshold", 1)
--local sand_threshold = vmg.define("sand_threshold", 0.75)
--local dirt_threshold = vmg.define("dirt_threshold", 0.5)

local light_depth = -13
local deep = -7000

-- Create a table of biome ids, so I can use the biomemap.
if not valc.biome_ids then
	local i
	valc.biome_ids = {}
	for name, desc in pairs(minetest.registered_biomes) do
		i = minetest.get_biome_id(desc.name)
		valc.biome_ids[i] = desc.name
	end
end

-- Get the content ids for all registered water plants.
for _, desc in pairs(valc.water_plants) do
	if type(desc.decoration) == 'string' then
		desc.content_id = minetest.get_content_id(desc.decoration)
	elseif type(desc.decoration) == 'table' then
		desc.content_id = minetest.get_content_id(desc.decoration[1])
	end
end


local data = {}


-- the mapgen function
function valc.generate(minp, maxp, seed)
	local t0 = os.clock()

	-- minp and maxp strings, used by logs
	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)

	-- The VoxelManipulator, a complicated but speedy method to set many nodes at the same time
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local heightmap = minetest.get_mapgen_object("heightmap")
	-- local heatmap = minetest.get_mapgen_object("heatmap")
	local gennotify = minetest.get_mapgen_object("gennotify")
	--print(dump(gennotify))
	local water_level = 1

	vm:get_data(data) -- data is the original array of content IDs (solely or mostly air)
	-- Be careful: emin ≠ minp and emax ≠ maxp !
	-- The data array is not limited by minp and maxp. It exceeds it by 16 nodes in the 6 directions.
	-- The real limits of data array are emin and emax.
	-- The VoxelArea is used to convert a position into an index for the array.
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local ystride = area.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.
	local zstride = area.zstride

	local chulens = vector.add(vector.subtract(maxp, minp), 1) -- Size of the generated area, used by noisemaps
	local minp2d = pos2d(minp)

	-- The biomemap is a table of biome index numbers for each horizontal
	--  location. It's created in the mapgen, and is right most of the time.
	--  It's off in about 1% of cases, for various reasons.
	-- Bear in mind that biomes can change from one voxel to the next.
	local biomemap = minetest.get_mapgen_object("biomemap")

	-- Calculate the noise values
	local n13 = valc.noisemap(13, minp2d, chulens)
	local n14 = valc.noisemap(14, minp2d, chulens)
	local n15 = valc.noisemap(15, minp2d, chulens)
	local n16 = valc.noisemap(16, minp2d, chulens)
	local n21 = valc.noisemap(21, minp2d, chulens)
	local n22 = valc.noisemap(22, minp2d, chulens)
	local n23 = valc.noisemap(23, minp2d, chulens)

	local node_match_cache = {}

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	-- the mapgen algorithm
	local index_2d = 0
	local write = false
	local relight = false
	local huge_cave = false
	local hug

	if valc.use_gennotify then
		if gennotify.alternative_cave then
			huge_cave = true
		end
	elseif maxp.y < -300 then
		if gennotify.alternative_cave then
			huge_cave = true
		end

		hug = survey(data, area, maxp, minp, node['lava'], node['water'], node['air'])

		if huge_cave ~= hug then
			print("fake gennotify screwed up")
		end
	end


	local index_3d, air_count, ground
	local index_3d_below, index_3d_above, surround
	local v13, v14, v15, v16
	local n, biome, sr, placeable, pos, count
	local stone_type, stone_depth, n23_val
	local soil, max

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index_2d = index_2d + 1

			index_3d = area:index(x, maxp.y, z) -- index of the data array, matching the position {x, y, z}
			air_count = 0
			ground = heightmap[index_2d]
			--if ground >= minp.y and ground <= maxp.y then
			--	local index_ground = index_3d - ystride * (maxp.y - ground)
			--	if data[index_ground] == node["air"] then
			--		print("*** bad heightmap at ("..x..","..ground..","..z..")")
			--		--ground = -31000
			--	end
			--end

			v13, v14, v15, v16 = n13[index_2d], n14[index_2d], n15[index_2d], n16[index_2d] -- take the noise values for 2D noises

			for y = maxp.y, minp.y, -1 do -- for each node in vertical line
				index_3d_below = index_3d - ystride
				index_3d_above = index_3d + ystride
				surround = true

				-- Determine if a plant/dirt block can be placed without showing.
				-- Avoid the edges of the chunk, just to make things easier.
				if y < maxp.y and x > minp.x and x < maxp.x and z > minp.z and z < maxp.z and (data[index_3d] == node["sand"] or data[index_3d] == node["dirt"]) then
					if data[index_3d_above] == node["river_water_source"] or data[index_3d_above] == node["water_source"] then
						-- Check to make sure that a plant root is fully surrounded.
						-- This is due to the kludgy way you have to make water plants
						--  in minetest, to avoid bubbles.
						for x1 = -1,1,2 do
							n = data[index_3d+x1] 
							if n == node["river_water_source"] or n == node["water_source"] or n == node["air"] then
								surround = false
							end
						end
						for z1 = -zstride,zstride,2*zstride do
							n = data[index_3d+z1] 
							if n == node["river_water_source"] or n == node["water_source"] or n == node["air"] then
								surround = false
							end
						end
					end

					if y >= light_depth and (data[index_3d] == node["sand"] or data[index_3d] == node["dirt"]) and (data[index_3d_above] == node["water_source"] or data[index_3d_above] == node["river_water_source"]) then
						-- Check the biomes and plant water plants, if called for.
						biome = valc.biome_ids[biomemap[index_2d]]
						if y < water_level and data[index_3d_above + ystride] == node["water_source"] and table.contains(coral_biomes, biome) and n21[index_2d] < -0.1 and math.random(1,3) ~= 1 then
							sr = math.random(1,100)
							if sr < 4 then
								data[index_3d_above] = node["brain_coral"]
							elseif sr < 6 then
								data[index_3d_above] = node["dragon_eye"]
							elseif sr < 35 then
								data[index_3d_above] = node["staghorn_coral"]
							elseif sr < 100 then
								data[index_3d_above] = node["pillar_coral"]
							end
						elseif surround then
							for _, desc in pairs(valc.water_plants) do
								placeable = false

								if not node_match_cache[desc] then
									node_match_cache[desc] = {}
								end

								if node_match_cache[desc][data[index_3d]] then
									placeable = node_match_cache[desc][data[index_3d]]
								else
									-- This is a great way to match all node type strings
									-- against a given node (or nodes). However, it's slow.
									-- To speed it up, we cache the results for each plant
									-- on each node, and avoid calling find_nodes every time.
									pos, count = minetest.find_nodes_in_area({x=x,y=y,z=z}, {x=x,y=y,z=z}, desc.place_on)
									if #pos > 0 then
										placeable = true
									end
									node_match_cache[desc][data[index_3d]] = placeable 
								end

								if placeable and desc.fill_ratio and desc.content_id then
									biome = valc.biome_ids[biomemap[index_2d]]

									if not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome)) then
										if math.random() <= desc.fill_ratio then
											data[index_3d] = desc.content_id
											write = true
										end
									end
								end
							end
						end
					end
				end

				-- on top of the water
				if y > minp.y and data[index_3d] == node["air"] and data[index_3d_below] == node["river_water_source"] then
					biome = valc.biome_ids[biomemap[index_2d]]
					-- I haven't figured out what the decoration manager is
					--  doing with the noise functions, but this works ok.
					if table.contains(water_lily_biomes, biome) and n21[index_2d] > 0.5 and math.random(1,15) == 1 then
						data[index_3d] = node["waterlily"]
						write = true
					end
				end

				-- Handle caves.
				if (y < ground - 5 or y < -100) and (data[index_3d] == node["air"] or data[index_3d] == node["river_water_source"] or data[index_3d] == node["water_source"]) then
					relight = true

					stone_type = node["stone"]
					stone_depth = 1
					n23_val = n23[index_2d] + n22[index_2d]
					if n23_val < -0.8 then
						if y < deep then
							stone_type = node["ice"]
							stone_depth = 2
						else
							stone_type = node["thinice"]
							stone_depth = 2
						end
					elseif n23_val < -0.7 then
						stone_type = node["lichen"]
					elseif n23_val < -0.3 then
						stone_type = node["moss"]
					elseif n23_val < 0.2 then
						stone_type = node["lichen"]
					elseif n23_val < 0.5 then
						stone_type = node["algae"]
					elseif n23_val < 0.6 then
						stone_type = node["salt"]
						stone_depth = 2
					elseif n23_val < 0.8 then
						stone_type = node["coalblock"]
						stone_depth = 2
					else
						stone_type = node["hcobble"]
					end
					--	"glow"

					-- Change stone per biome.
					if data[index_3d_below] == node["stone"] then
						data[index_3d_below] = stone_type
						if stone_depth == 2 then
							data[index_3d_below - ystride] = stone_type
						end
						write = true
					end
					if data[index_3d_above] == node["stone"] then
						data[index_3d_above] = stone_type
						if stone_depth == 2 then
							data[index_3d_above + ystride] = stone_type
						end
						write = true
					end

					if (data[index_3d_above] == node["lichen"] or data[index_3d_above] == node["moss"]) and math.random(1,20) == 1 then
						data[index_3d_above] = node["fungal_stone"]
						write = true
					end

					if data[index_3d] == node["air"] then
						sr = math.random(1,1000)

						-- fluids
						if (not huge_cave) and data[index_3d_below] == node["stone"] and sr < 10 then
								data[index_3d] = node["lava"]
						elseif (not huge_cave) and data[index_3d_below] == node["moss"] and sr < 10 then
								data[index_3d] = node["river_water_source"]
						-- hanging down
						elseif data[index_3d_above] == node["ice"] and sr < 80 then
							data[index_3d] = node["icicle_down"]
							write = true
						elseif (data[index_3d_above] == node["lichen"] or data[index_3d_above] == node["moss"] or data[index_3d_above] == node["algae"] or data[index_3d_above] == node["stone"]) and sr < 80 then
							if data[index_3d_above] == node["algae"] then
								data[index_3d] = node["stalactite_slimy"]
							elseif data[index_3d_above] == node["moss"] then
								data[index_3d] = node["stalactite_mossy"]
							else
								data[index_3d] = node["stalactite"]
							end
							write = true
						-- standing up
						elseif data[index_3d_below] == node["coalblock"] and sr < 20 then
							data[index_3d] = node["flame"]
						elseif data[index_3d_below] == node["ice"] and sr < 80 then
							data[index_3d] = node["icicle_up"]
							write = true
						elseif (data[index_3d_below] == node["lichen"] or data[index_3d_below] == node["algae"] or data[index_3d_below] == node["stone"] or data[index_3d_below] == node["moss"]) and sr < 80 then
							if data[index_3d_below] == node["algae"] then
								data[index_3d] = node["stalagmite_slimy"]
							elseif data[index_3d_below] == node["moss"] then
								data[index_3d] = node["stalagmite_mossy"]
							elseif data[index_3d_below] == node["lichen"] or data[index_3d_above] == node["stone"] then
								data[index_3d] = node["stalagmite"]
							end
						-- vegetation
						elseif (data[index_3d_below] == node["lichen"] or data[index_3d_below] == node["algae"]) and n23_val >= -0.7 then
							if sr < 110 then
								data[index_3d] = node["mushroom_red"]
							elseif sr < 140 then
								data[index_3d] = node["mushroom_brown"]
							elseif air_count > 1 and sr < 160 then
								data[index_3d_above] = node["mushroom_cap_huge"]
								data[index_3d] = node["mushroom_stem"]
							elseif air_count > 2 and sr < 170 then
								data[index_3d + 2 * ystride] = node["mushroom_cap_giant"]
								data[index_3d_above] = node["mushroom_stem"]
								data[index_3d] = node["mushroom_stem"]
							elseif huge_cave and air_count > 5 and sr < 180 then
								valc.make_fungal_tree(data, area, index_3d, math.random(2,math.min(air_count, 12)), node["fungal_tree_leaves"][math.random(1,#node["fungal_tree_leaves"])], node["fungal_tree_fruit"])
								data[index_3d_below] = node["dirt"]
								write = true
							elseif sr < 300 then
								data[index_3d_below] = node["dirt"]
								write = true
							end
							if data[index_3d] ~= node["air"] then
								data[index_3d_below] = node["dirt"]
								write = true
							end
						end
					end

					if data[index_3d] == node["air"] then
						air_count = air_count + 1
					end
				end

				if data[index_3d] == node["dirt"] or data[index_3d] == node["dirt_with_snow"] or data[index_3d] == node["dirt_with_grass"] or data[index_3d] == node["dirt_with_dry_grass"] or data[index_3d] == node["sand"] then
					-- Choose biome, by default normal dirt
					soil = "dirt"
					max = math.max(v13, v14, v15) -- the biome is the maximal of these 3 values.
					if max > dirt_threshold then -- if one of these values is bigger than dirt_threshold, make clayey, silty or sandy dirt, depending on the case. If none of clay, silt or sand is predominant, make normal dirt.
						if v13 == max then
							if v13 > clay_threshold then
								soil = "clay_over"
							else
								soil = "clay_under"
							end
						elseif v14 == max then
							if v14 > silt_threshold then
								soil = "silt_over"
							else
								soil = "silt_under"
							end
						else
							soil = "sand"
						end
					end

					if data[index_3d] == node["dirt"] then
						data[index_3d] = soil_translate[soil].dirt
						write = true
					elseif data[index_3d] == node["dirt_with_snow"] then
						data[index_3d] = soil_translate[soil].snow
						write = true
					elseif data[index_3d] == node["dirt_with_grass"] then
						data[index_3d] = soil_translate[soil].lawn
						write = true
					elseif data[index_3d] == node["dirt_with_dry_grass"] then
						data[index_3d] = soil_translate[soil].dry
						write = true
					elseif data[index_3d] == node["sand"] then
						sr = math.random(1,50)
						if valc.glow and sr == 1 then
							data[index_3d] = node["glowing_sand"]
							write = true
						elseif sr < 10 then
							data[index_3d] = node["sand_with_rocks"]
							write = true
						end
					end
				end

				if data[index_3d] ~= node["air"] then
					air_count = 0
				end
				index_3d = index_3d_below
			end
		end
	end

	local t2 = os.clock()

	-- execute voxelmanip boring stuff to write to the map...
	if write then
		vm:set_data(data)
	end

	local t3 = os.clock()

	if write then
		-- probably not necessary
		if relight then
			--vm:set_lighting({day = 10, night = 10})
		end

		-- This seems to be necessary to avoid lighting problems.
		vm:calc_lighting()

		-- probably not necessary
		--vm:update_liquids()
	end

	local t4 = os.clock()

	if write then
		vm:write_to_map()
	end

	local t5 = os.clock()

	table.insert(mapgen_times.noisemaps, 0)
	table.insert(mapgen_times.preparation, t1 - t0)
	table.insert(mapgen_times.loops, t2 - t1)
	table.insert(mapgen_times.writing, t3 - t2 + t5 - t4)
	table.insert(mapgen_times.liquid_lighting, t4 - t3)
	table.insert(mapgen_times.make_chunk, t5 - t0)

	-- Deal with memory issues. This, of course, is supposed to be automatic.
	local mem = math.floor(collectgarbage("count")/1024)
	if mem > 500 then
		print("Valleys_c is manually collecting garbage as memory use has exceeded 500K.")
		collectgarbage("collect")
	end
end

local function mean( t )
  local sum = 0
  local count= 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end

minetest.register_on_shutdown(function()
	if #mapgen_times.make_chunk == 0 then
		return
	end

	local average, standard_dev
	minetest.log("Valleys_C lua Mapgen Times:")

	average = mean(mapgen_times.liquid_lighting)
	minetest.log("  liquid_lighting: - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.loops)
	minetest.log("  loops: - - - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.make_chunk)
	minetest.log("  makeChunk: - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.noisemaps)
	minetest.log("  noisemaps: - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.preparation)
	minetest.log("  preparation: - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.writing)
	minetest.log("  writing: - - - - - - - - - - - - - - - -  "..average)
end)


-- Call the mapgen function valc.generate on mapgen.
--  (located in voxel.lua)
minetest.register_on_generated(valc.generate)

