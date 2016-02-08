----------------------
-- Voxel Manip Loop --
----------------------

-- This is only used to handle cases the decoration manager can't,
--  such as water plants and cave decorations.


local pr = PseudoRandom(os.time())


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

-- Ground nodes
node["stone"] = minetest.get_content_id("default:stone")
node["dirt"] = minetest.get_content_id("default:dirt")
node["dirt_with_grass"] = minetest.get_content_id("default:dirt_with_grass")
node["dirt_with_dry_grass"] = minetest.get_content_id("default:dirt_with_dry_grass")
node["snow"] = minetest.get_content_id("default:dirt_with_snow")
node["sand"] = minetest.get_content_id("default:sand")
node["sandstone"] = minetest.get_content_id("default:sandstone")
node["desert_sand"] = minetest.get_content_id("default:desert_sand")
node["gravel"] = minetest.get_content_id("default:gravel")
node["desertstone"] = minetest.get_content_id("default:desert_stone")
node["river_water_source"] = minetest.get_content_id("default:river_water_source")
node["water_source"] = minetest.get_content_id("default:water_source")
node["lava"] = minetest.get_content_id("default:lava_source")

node["sand_with_rocks"] = minetest.get_content_id("valleys_c:sand_with_rocks")
node["glowing_sand"] = minetest.get_content_id("valleys_c:glowing_sand")
node["fungal_stone"] = minetest.get_content_id("valleys_c:glowing_fungal_stone")
node["stalactite"] = minetest.get_content_id("valleys_c:stalactite")
node["stalactite_slimy"] = minetest.get_content_id("valleys_c:stalactite_slimy")
node["stalactite_mossy"] = minetest.get_content_id("valleys_c:stalactite_mossy")
node["stalagmite"] = minetest.get_content_id("valleys_c:stalagmite")
node["stalagmite_slimy"] = minetest.get_content_id("valleys_c:stalagmite_slimy")
node["stalagmite_mossy"] = minetest.get_content_id("valleys_c:stalagmite_mossy")
node["mushroom_cap_giant"] = minetest.get_content_id("valleys_c:giant_mushroom_cap")
node["mushroom_cap_huge"] = minetest.get_content_id("valleys_c:huge_mushroom_cap")
node["mushroom_stem"] = minetest.get_content_id("valleys_c:giant_mushroom_stem")
node["mushroom_red"] = minetest.get_content_id("flowers:mushroom_red")
node["mushroom_brown"] = minetest.get_content_id("flowers:mushroom_brown")
node["waterlily"] = minetest.get_content_id("flowers:waterlily")
node["brain_coral"] = minetest.get_content_id("valleys_c:brain_coral")
node["dragon_eye"] = minetest.get_content_id("valleys_c:dragon_eye")
node["pillar_coral"] = minetest.get_content_id("valleys_c:pillar_coral")
node["staghorn_coral"] = minetest.get_content_id("valleys_c:staghorn_coral")

node["dirt_clay"] = minetest.get_content_id("valleys_c:dirt_clayey")
node["lawn_clay"] = minetest.get_content_id("valleys_c:dirt_clayey_with_grass")
node["dry_clay"] = minetest.get_content_id("valleys_c:dirt_clayey_with_dry_grass")
node["snow_clay"] = minetest.get_content_id("valleys_c:dirt_clayey_with_snow")
node["dirt_silt"] = minetest.get_content_id("valleys_c:dirt_silty")
node["lawn_silt"] = minetest.get_content_id("valleys_c:dirt_silty_with_grass")
node["dry_silt"] = minetest.get_content_id("valleys_c:dirt_silty_with_dry_grass")
node["snow_silt"] = minetest.get_content_id("valleys_c:dirt_silty_with_snow")
node["dirt_sand"] = minetest.get_content_id("valleys_c:dirt_sandy")
node["lawn_sand"] = minetest.get_content_id("valleys_c:dirt_sandy_with_grass")
node["dry_sand"] = minetest.get_content_id("valleys_c:dirt_sandy_with_dry_grass")
node["snow_sand"] = minetest.get_content_id("valleys_c:dirt_sandy_with_snow")
node["silt"] = minetest.get_content_id("valleys_c:silt")
node["clay"] = minetest.get_content_id("valleys_c:red_clay")

-- Air and Ignore
node["air"] = minetest.get_content_id("air")
node["ignore"] = minetest.get_content_id("ignore")

node["ice"] = minetest.get_content_id("default:ice")
node["thinice"] = minetest.get_content_id("valleys_c:thin_ice")
--node["crystal"] = minetest.get_content_id("valleys_c:glow_crystal")
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
node["moss"] = minetest.get_content_id("valleys_c:stone_with_moss")
node["lichen"] = minetest.get_content_id("valleys_c:stone_with_lichen")
node["algae"] = minetest.get_content_id("valleys_c:stone_with_algae")
node["salt"] = minetest.get_content_id("valleys_c:stone_with_salt")
node["hcobble"] = minetest.get_content_id("valleys_c:hot_cobble")
node["gobsidian"] = minetest.get_content_id("valleys_c:glow_obsidian")
node["gobsidian2"] = minetest.get_content_id("valleys_c:glow_obsidian_2")
node["coalblock"] = minetest.get_content_id("default:coalblock")
node["obsidian"] = minetest.get_content_id("default:obsidian")
--node["desand"] = minetest.get_content_id("default:desert_sand")
--node["coaldust"] = minetest.get_content_id("valleys_c:coal_dust")
--node["fungus"] = minetest.get_content_id("valleys_c:fungus")
--node["mycena"] = minetest.get_content_id("valleys_c:mycena")
--node["worm"] = minetest.get_content_id("valleys_c:glow_worm")
node["icicle_up"] = minetest.get_content_id("valleys_c:icicle_up")
node["icicle_down"] = minetest.get_content_id("valleys_c:icicle_down")
node["flame"] = minetest.get_content_id("valleys_c:constant_flame")
--node["fountain"] = minetest.get_content_id("valleys_c:s_fountain")
--node["fortress"] = minetest.get_content_id("valleys_c:s_fortress")

node["fungal_tree_leaves"] = {}
for _, name in pairs(valc.fungal_tree_leaves) do
	node["fungal_tree_leaves"][#node["fungal_tree_leaves"]+1] = minetest.get_content_id(name)
end
node["fungal_tree_fruit"] = minetest.get_content_id("valleys_c:fungal_tree_fruit")

local soil_translate = {}
soil_translate["clay_over"] = { dirt = node["clay"], lawn = node["clay"], dry = node["clay"], snow = node["clay"], }
soil_translate["clay_under"] = { dirt = node["dirt_clay"], lawn = node["lawn_clay"], dry = node["dry_clay"], snow = node["snow_clay"], }
soil_translate["silt_over"] = { dirt = node["silt"], lawn = node["silt"], dry = node["silt"], snow = node["silt"], }
soil_translate["silt_under"] = { dirt = node["dirt_silt"], lawn = node["lawn_silt"], dry = node["dry_silt"], snow = node["snow_silt"], }
soil_translate["sand"] = { dirt = node["dirt_sand"], lawn = node["lawn_sand"], dry = node["dry_sand"], snow = node["snow_sand"], }
soil_translate["dirt"] = { dirt = node["dirt"], lawn = node["dirt_with_grass"], dry = node["dirt_with_dry_grass"], snow = node["snow"], }

local water_lily_biomes = {"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest"}
local coral_biomes = {"stone_grassland_ocean", "coniferous_forest_ocean", "sandstone_grassland_ocean", "deciduous_forest_ocean", "desert_ocean", "savanna_ocean", "rainforest_ocean", }

local clay_threshold = 1
local silt_threshold = 1
local sand_threshold = 0.75
local dirt_threshold = 0.75

--local clay_threshold = vmg.define("clay_threshold", 1)
--local silt_threshold = vmg.define("silt_threshold", 1)
--local sand_threshold = vmg.define("sand_threshold", 0.75)
--local dirt_threshold = vmg.define("dirt_threshold", 0.5)

local light_depth = -13

-- Create a table of biome ids, so I can use the biomemap.
if not valc.biome_ids then
	valc.biome_ids = {}
	for name, desc in pairs(minetest.registered_biomes) do
		local i = minetest.get_biome_id(desc.name)
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

	local data = vm:get_data() -- data is the original array of content IDs (solely or mostly air)
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
	local huge_cave = true

	if gennotify.alternative_cave then
		huge_cave = true
	end

	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			index_2d = index_2d + 1

			local index_3d = area:index(x, maxp.y, z) -- index of the data array, matching the position {x, y, z}
			local air_count = 0
			local ground = math.max(heightmap[index_2d], 0) - 5

			local v13, v14, v15, v16 = n13[index_2d], n14[index_2d], n15[index_2d], n16[index_2d] -- take the noise values for 2D noises

			for y = maxp.y, minp.y, -1 do -- for each node in vertical line
				local index_3d_below = index_3d - ystride
				local index_3d_above = index_3d + ystride
				local surround = true

				-- Determine if a plant/dirt block can be placed without showing.
				-- Avoid the edges of the chunk, just to make things easier.
				if y < maxp.y and x > minp.x and x < maxp.x and z > minp.z and z < maxp.z and (data[index_3d] == node["sand"] or data[index_3d] == node["dirt"]) then
					if data[index_3d_above] == node["river_water_source"] or data[index_3d_above] == node["water_source"] then
						-- Check to make sure that a plant root is fully surrounded.
						-- This is due to the kludgy way you have to make water plants
						--  in minetest, to avoid bubbles.
						for x1 = -1,1,2 do
							local n = data[index_3d+x1] 
							if n == node["river_water_source"] or n == node["water_source"] or n == node["air"] then
								surround = false
							end
						end
						for z1 = -zstride,zstride,2*zstride do
							local n = data[index_3d+z1] 
							if n == node["river_water_source"] or n == node["water_source"] or n == node["air"] then
								surround = false
							end
						end
					end

					if y >= light_depth and (data[index_3d] == node["sand"] or data[index_3d] == node["dirt"]) and (data[index_3d_above] == node["water_source"] or data[index_3d_above] == node["river_water_source"]) then
						-- Check the biomes and plant water plants, if called for.
						local biome = valc.biome_ids[biomemap[index_2d]]
						if y < water_level and data[index_3d_above + ystride] == node["water_source"] and table.contains(coral_biomes, biome) and n21[index_2d] < -0.1 and pr:next(1,3) ~= 1 then
							local sr = pr:next(1,100)
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
								local placeable = false

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
									local pos, count = minetest.find_nodes_in_area({x=x,y=y,z=z}, {x=x,y=y,z=z}, desc.place_on)
									if #pos > 0 then
										placeable = true
									end
									node_match_cache[desc][data[index_3d]] = placeable 
								end

								if placeable and desc.fill_ratio and desc.content_id then
									local biome = valc.biome_ids[biomemap[index_2d]]

									if not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome)) then
										if pr:next() / 32767 <= desc.fill_ratio then
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
					local biome = valc.biome_ids[biomemap[index_2d]]
					-- I haven't figured out what the decoration manager is
					--  doing with the noise functions, but this works ok.
					if table.contains(water_lily_biomes, biome) and n21[index_2d] > 0.5 and pr:next(1,15) == 1 then
						data[index_3d] = node["waterlily"]
						write = true
					end
				end

				-- Handle caves.
				if y < ground and (data[index_3d] == node["air"] or data[index_3d] == node["river_water_source"] or data[index_3d] == node["water_source"]) then
					relight = true

					local under_biome
					local deep = -7000
					local stone_type = node["stone"]
					local stone_depth = 1
					local n23_val = n23[index_2d] + n22[index_2d]
					if n23_val < -0.8 then
						if y < deep then
							under_biome = "deep"
							stone_type = node["ice"]
							stone_depth = 2
						else
							under_biome = "ice"
							stone_type = node["thinice"]
							stone_depth = 2
						end
					elseif n23_val < -0.7 then
						under_biome = "eeking"
						stone_type = node["lichen"]
					elseif n23_val < -0.3 then
						under_biome = "moss"
						stone_type = node["moss"]
					elseif n23_val < 0.2 then
						under_biome = "fungal"
						stone_type = node["lichen"]
					elseif n23_val < 0.5 then
						under_biome = "algae"
						stone_type = node["algae"]
					elseif n23_val < 0.6 then
						under_biome = "salt"
						stone_type = node["salt"]
						stone_depth = 2
					elseif n23_val < 0.8 then
						under_biome = "coal"
						stone_type = node["coalblock"]
						stone_depth = 2
					else
						under_biome = "hot"
						stone_type = node["hcobble"]
					end
					--	under_biome = "glow"

					-- Change stone per biome.
					if data[index_3d_below] == node["stone"] then
						data[index_3d_below] = stone_type
						if stone_depth == 2 then
							data[index_3d_below - ystride] = stone_type
						end
						write = true
					elseif data[index_3d_above] == node["stone"] then
						data[index_3d_above] = stone_type
						if stone_depth == 2 then
							data[index_3d_above + ystride] = stone_type
						end
						write = true
					end

					if (data[index_3d_above] == node["lichen"] or data[index_3d_above] == node["moss"]) and pr:next(1,20) == 1 then
						data[index_3d_above] = node["fungal_stone"]
						write = true
					end

					if data[index_3d] == node["air"] then
						local sr = pr:next(1,1000)

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
						elseif (data[index_3d_below] == node["lichen"] or data[index_3d_below] == node["algae"]) and under_biome ~= "eeking" then
							if sr < 110 then
								data[index_3d] = node["mushroom_red"]
								data[index_3d_below] = node["dirt"]
								write = true
							elseif sr < 140 then
								data[index_3d] = node["mushroom_brown"]
								data[index_3d_below] = node["dirt"]
								write = true
							elseif air_count > 1 and sr < 160 then
								data[index_3d_above] = node["mushroom_cap_huge"]
								data[index_3d] = node["mushroom_stem"]
								data[index_3d_below] = node["dirt"]
								write = true
							elseif air_count > 2 and sr < 170 then
								data[index_3d + 2 * ystride] = node["mushroom_cap_giant"]
								data[index_3d_above] = node["mushroom_stem"]
								data[index_3d] = node["mushroom_stem"]
								data[index_3d_below] = node["dirt"]
								write = true
							elseif huge_cave and air_count > 5 and sr < 180 then
								valc.make_fungal_tree(data, area, index_3d, pr:next(2,math.min(air_count, 12)), node["fungal_tree_leaves"][pr:next(1,#node["fungal_tree_leaves"])], node["fungal_tree_fruit"])
								data[index_3d_below] = node["dirt"]
							elseif sr < 300 then
								data[index_3d_below] = node["dirt"]
								write = true
							end
						end
					end

					if data[index_3d] == node["air"] then
						air_count = air_count + 1
					end
				end

				if data[index_3d] == node["dirt"] or data[index_3d] == node["snow"] or data[index_3d] == node["dirt_with_grass"] or data[index_3d] == node["dirt_with_dry_grass"] or data[index_3d] == node["sand"] then
					-- Choose biome, by default normal dirt
					local soil = "dirt"
					local max = math.max(v13, v14, v15) -- the biome is the maximal of these 3 values.
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
					elseif data[index_3d] == node["snow"] then
						data[index_3d] = soil_translate[soil].snow
						write = true
					elseif data[index_3d] == node["dirt_with_grass"] then
						data[index_3d] = soil_translate[soil].lawn
						write = true
					elseif data[index_3d] == node["dirt_with_dry_grass"] then
						data[index_3d] = soil_translate[soil].dry
						write = true
					elseif data[index_3d] == node["sand"] then
						local sr = pr:next(1,50)
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

