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

-- Ground nodes
local c_stone = minetest.get_content_id("default:stone")
local c_dirt = minetest.get_content_id("default:dirt")
local c_dirt_with_grass = minetest.get_content_id("default:dirt_with_grass")
local c_dirt_with_dry_grass = minetest.get_content_id("default:dirt_with_dry_grass")
local c_snow = minetest.get_content_id("default:dirt_with_snow")
local c_sand = minetest.get_content_id("default:sand")
local c_sandstone = minetest.get_content_id("default:sandstone")
local c_desert_sand = minetest.get_content_id("default:desert_sand")
local c_gravel = minetest.get_content_id("default:gravel")
local c_desertstone = minetest.get_content_id("default:desert_stone")
local c_river_water_source = minetest.get_content_id("default:river_water_source")
local c_water_source = minetest.get_content_id("default:water_source")
local c_lava = minetest.get_content_id("default:lava_source")

local c_sand_with_rocks = minetest.get_content_id("valleys_c:sand_with_rocks")
local c_glowing_sand = minetest.get_content_id("valleys_c:glowing_sand")
local c_fungal_stone = minetest.get_content_id("valleys_c:glowing_fungal_stone")
local c_stalactite = minetest.get_content_id("valleys_c:stalactite")
local c_stalactite_slimy = minetest.get_content_id("valleys_c:stalactite_slimy")
local c_stalactite_mossy = minetest.get_content_id("valleys_c:stalactite_mossy")
local c_stalagmite = minetest.get_content_id("valleys_c:stalagmite")
local c_stalagmite_slimy = minetest.get_content_id("valleys_c:stalagmite_slimy")
local c_stalagmite_mossy = minetest.get_content_id("valleys_c:stalagmite_mossy")
local c_mushroom_cap_giant = minetest.get_content_id("valleys_c:giant_mushroom_cap")
local c_mushroom_cap_huge = minetest.get_content_id("valleys_c:huge_mushroom_cap")
local c_mushroom_stem = minetest.get_content_id("valleys_c:giant_mushroom_stem")
local c_mushroom_red = minetest.get_content_id("flowers:mushroom_red")
local c_mushroom_brown = minetest.get_content_id("flowers:mushroom_brown")
local c_waterlily = minetest.get_content_id("flowers:waterlily")
local c_brain_coral = minetest.get_content_id("valleys_c:brain_coral")
local c_dragon_eye = minetest.get_content_id("valleys_c:dragon_eye")
local c_pillar_coral = minetest.get_content_id("valleys_c:pillar_coral")
local c_staghorn_coral = minetest.get_content_id("valleys_c:staghorn_coral")

local c_dirt_clay = minetest.get_content_id("valleys_c:dirt_clayey")
local c_lawn_clay = minetest.get_content_id("valleys_c:dirt_clayey_with_grass")
local c_dry_clay = minetest.get_content_id("valleys_c:dirt_clayey_with_dry_grass")
local c_snow_clay = minetest.get_content_id("valleys_c:dirt_clayey_with_snow")
local c_dirt_silt = minetest.get_content_id("valleys_c:dirt_silty")
local c_lawn_silt = minetest.get_content_id("valleys_c:dirt_silty_with_grass")
local c_dry_silt = minetest.get_content_id("valleys_c:dirt_silty_with_dry_grass")
local c_snow_silt = minetest.get_content_id("valleys_c:dirt_silty_with_snow")
local c_dirt_sand = minetest.get_content_id("valleys_c:dirt_sandy")
local c_lawn_sand = minetest.get_content_id("valleys_c:dirt_sandy_with_grass")
local c_dry_sand = minetest.get_content_id("valleys_c:dirt_sandy_with_dry_grass")
local c_snow_sand = minetest.get_content_id("valleys_c:dirt_sandy_with_snow")
local c_silt = minetest.get_content_id("valleys_c:silt")
local c_clay = minetest.get_content_id("valleys_c:red_clay")

-- Air and Ignore
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")

local c_ice = minetest.get_content_id("default:ice")
local c_thinice = minetest.get_content_id("valleys_c:thin_ice")
--local c_crystal = minetest.get_content_id("valleys_c:glow_crystal")
--local c_gem1 = minetest.get_content_id("valleys_c:glow_gem")
--local c_gem2 = minetest.get_content_id("valleys_c:glow_gem_2")
--local c_gem3 = minetest.get_content_id("valleys_c:glow_gem_3")
--local c_gem4 = minetest.get_content_id("valleys_c:glow_gem_4")
--local c_gem5 = minetest.get_content_id("valleys_c:glow_gem_5")
--local c_saltgem1 = minetest.get_content_id("valleys_c:salt_gem")
--local c_saltgem2 = minetest.get_content_id("valleys_c:salt_gem_2")
--local c_saltgem3 = minetest.get_content_id("valleys_c:salt_gem_3")
--local c_saltgem4 = minetest.get_content_id("valleys_c:salt_gem_4")
--local c_saltgem5 = minetest.get_content_id("valleys_c:salt_gem_5")
--local c_spike1 = minetest.get_content_id("valleys_c:spike")
--local c_spike2 = minetest.get_content_id("valleys_c:spike_2")
--local c_spike3 = minetest.get_content_id("valleys_c:spike_3")
--local c_spike4 = minetest.get_content_id("valleys_c:spike_4")
--local c_spike5 = minetest.get_content_id("valleys_c:spike_5")
local c_moss = minetest.get_content_id("valleys_c:stone_with_moss")
local c_lichen = minetest.get_content_id("valleys_c:stone_with_lichen")
local c_algae = minetest.get_content_id("valleys_c:stone_with_algae")
local c_salt = minetest.get_content_id("valleys_c:stone_with_salt")
--local c_hcobble = minetest.get_content_id("valleys_c:hot_cobble")
local c_gobsidian = minetest.get_content_id("valleys_c:glow_obsidian")
local c_gobsidian2 = minetest.get_content_id("valleys_c:glow_obsidian_2")
local c_coalblock = minetest.get_content_id("default:coalblock")
--local c_desand = minetest.get_content_id("default:desert_sand")
--local c_coaldust = minetest.get_content_id("valleys_c:coal_dust")
--local c_fungus = minetest.get_content_id("valleys_c:fungus")
--local c_mycena = minetest.get_content_id("valleys_c:mycena")
--local c_worm = minetest.get_content_id("valleys_c:glow_worm")
local c_icicle_up = minetest.get_content_id("valleys_c:icicle_up")
local c_icicle_down = minetest.get_content_id("valleys_c:icicle_down")
--local c_flame = minetest.get_content_id("valleys_c:constant_flame")
--local c_fountain = minetest.get_content_id("valleys_c:s_fountain")
--local c_fortress = minetest.get_content_id("valleys_c:s_fortress")

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

	local node_match_cache = {}
	local soil_translate = {}

	soil_translate["clay_over"] = { dirt = c_clay, lawn = c_clay, dry = c_clay, snow = c_clay, }
	soil_translate["clay_under"] = { dirt = c_dirt_clay, lawn = c_lawn_clay, dry = c_dry_clay, snow = c_snow_clay, }
	soil_translate["silt_over"] = { dirt = c_silt, lawn = c_silt, dry = c_silt, snow = c_silt, }
	soil_translate["silt_under"] = { dirt = c_dirt_silt, lawn = c_lawn_silt, dry = c_dry_silt, snow = c_snow_silt, }
	soil_translate["sand"] = { dirt = c_dirt_sand, lawn = c_lawn_sand, dry = c_dry_sand, snow = c_snow_sand, }
	soil_translate["dirt"] = { dirt = c_dirt, lawn = c_dirt_with_grass, dry = c_dirt_with_dry_grass, snow = c_snow, }

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	-- the mapgen algorithm
	local index_2d = 0
	local write = false
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
				if y < maxp.y and x > minp.x and x < maxp.x and z > minp.z and z < maxp.z and (data[index_3d] == c_sand or data[index_3d] == c_dirt) then
					if data[index_3d_above] == c_river_water_source or data[index_3d_above] == c_water_source then
						-- Check to make sure that a plant root is fully surrounded.
						-- This is due to the kludgy way you have to make water plants
						--  in minetest, to avoid bubbles.
						for x1 = -1,1,2 do
							local n = data[index_3d+x1] 
							if n == c_river_water_source or n == c_water_source or n == c_air then
								surround = false
							end
						end
						for z1 = -zstride,zstride,2*zstride do
							local n = data[index_3d+z1] 
							if n == c_river_water_source or n == c_water_source or n == c_air then
								surround = false
							end
						end
					end

					if y >= light_depth and (data[index_3d] == c_sand or data[index_3d] == c_dirt) and (data[index_3d_above] == c_water_source or data[index_3d_above] == c_river_water_source) then
						-- Check the biomes and plant water plants, if called for.
						local biome = valc.biome_ids[biomemap[index_2d]]
						if y < water_level and data[index_3d_above + ystride] == c_water_source and table.contains(coral_biomes, biome) and n21[index_2d] < -0.1 and math.random(3) ~= 1 then
							local sr = math.random(100)
							if sr < 4 then
								data[index_3d_above] = c_brain_coral
							elseif sr < 6 then
								data[index_3d_above] = c_dragon_eye
							elseif sr < 35 then
								data[index_3d_above] = c_staghorn_coral
							elseif sr < 100 then
								data[index_3d_above] = c_pillar_coral
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
				if y > minp.y and data[index_3d] == c_air and data[index_3d_below] == c_river_water_source then
					local biome = valc.biome_ids[biomemap[index_2d]]
					-- I haven't figured out what the decoration manager is
					--  doing with the noise functions, but this works ok.
					if table.contains(water_lily_biomes, biome) and n21[index_2d] > 0.5 and math.random(15) == 1 then
						data[index_3d] = c_waterlily
						write = true
					end
				end

				-- Handle caves.
				if y < ground and (data[index_3d] == c_air or data[index_3d] == c_river_water_source or data[index_3d] == c_water_source) then
					local under_biome
					local deep = -7000
					local stone_type = c_stone
					local stone_depth = 1
					local n21_val = n21[index_2d] + n22[index_2d]
					if n21_val < -0.5 then
						if y < deep then
							under_biome = "glow"
							if math.random(2) == 1 then
								stone_type = c_gobsidian
							else
								stone_type = c_gobsidian2
							end
						else
						end
					elseif n21_val < -0.2 then
						if y < deep then
							under_biome = "coal"
							stone_type = c_coalblock
							stone_depth = 2
						else
							under_biome = "algae"
							stone_type = c_algae
						end
					elseif n21_val < 0.2 then
						under_biome = "fungal"
						stone_type = c_lichen
					elseif n21_val < 0.5 then
						if y < deep then
							under_biome = "salt"
							stone_type = c_salt
							stone_depth = 2
						else
							under_biome = "moss"
							stone_type = c_moss
						end
					else
						if y < deep then
							under_biome = "deep"
							stone_type = c_ice
							stone_depth = 2
						else
							under_biome = "ice"
							stone_type = c_thinice
							stone_depth = 2
						end
					end

					-- Change stone per biome.
					if data[index_3d_below] == c_stone then
						data[index_3d_below] = stone_type
						if stone_depth == 2 then
							data[index_3d - 2 * ystride] = stone_type
						end
						write = true
					elseif data[index_3d_above] == c_stone then
						data[index_3d_above] = stone_type
						if stone_depth == 2 then
							data[index_3d + 2 * ystride] = stone_type
						end
						write = true
					end

					if (data[index_3d_above] == c_lichen or data[index_3d_above] == c_moss) and math.random(20) == 1 then
						data[index_3d_above] = c_fungal_stone
						write = true
					end

					if data[index_3d] == c_air then
						local sr = math.random(1000)

						if data[index_3d_above] == c_lichen or data[index_3d_above] == c_moss or data[index_3d_above] == c_algae and sr < 135 then
							if data[index_3d_above] == c_algae then
								data[index_3d] = c_stalactite_slimy
							elseif data[index_3d_above] == c_moss then
								data[index_3d] = c_stalactite_mossy
							elseif data[index_3d_above] == c_lichen then
								data[index_3d] = c_stalactite
							end
							write = true
						elseif data[index_3d_above] == c_ice and sr < 135 then
							data[index_3d] = c_icicle_down
							write = true
						elseif data[index_3d_below] == c_ice and sr < 200 then
							data[index_3d] = c_icicle_up
							write = true
						elseif data[index_3d_below] == c_lichen or data[index_3d_below] == c_algae then
							if sr < 40 then
								data[index_3d] = c_mushroom_red
								data[index_3d_below] = c_dirt
								write = true
							elseif sr < 70 then
								data[index_3d] = c_mushroom_brown
								data[index_3d_below] = c_dirt
								write = true
							elseif air_count > 1 and sr < 100 then
								data[index_3d_above] = c_mushroom_cap_huge
								data[index_3d] = c_mushroom_stem
								data[index_3d_below] = c_dirt
								write = true
							elseif air_count > 2 and sr < 120 then
								data[index_3d + 2 * ystride] = c_mushroom_cap_giant
								data[index_3d_above] = c_mushroom_stem
								data[index_3d] = c_mushroom_stem
								data[index_3d_below] = c_dirt
								write = true
							elseif sr < 180 then
								data[index_3d_below] = c_dirt
								write = true
							elseif sr < 305 then
								if data[index_3d_below] == c_algae then
									data[index_3d] = c_stalagmite_slimy
								elseif data[index_3d_below] == c_moss then
									data[index_3d] = c_stalagmite_mossy
								elseif data[index_3d_below] == c_lichen then
									data[index_3d] = c_stalagmite
								end
							end
						elseif data[index_3d_below] == c_moss and sr < 3 then
							data[index_3d_below] = c_river_water_source
							data[index_3d - 2 * ystride] = c_fungal_stone
						end
					end

					if data[index_3d] == c_air then
						air_count = air_count + 1
					end
				end

				if data[index_3d] == c_dirt or data[index_3d] == c_snow or data[index_3d] == c_dirt_with_grass or data[index_3d] == c_dirt_with_dry_grass or data[index_3d] == c_sand then
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

					if data[index_3d] == c_dirt then
						data[index_3d] = soil_translate[soil].dirt
						write = true
					elseif data[index_3d] == c_snow then
						data[index_3d] = soil_translate[soil].snow
						write = true
					elseif data[index_3d] == c_dirt_with_grass then
						data[index_3d] = soil_translate[soil].lawn
						write = true
					elseif data[index_3d] == c_dirt_with_dry_grass then
						data[index_3d] = soil_translate[soil].dry
						write = true
					elseif data[index_3d] == c_sand then
						local sr = math.random(50)
						if valc.glow and sr == 1 then
							data[index_3d] = c_glowing_sand
							write = true
						elseif sr < 10 then
							data[index_3d] = c_sand_with_rocks
							write = true
						end
					end
				end

				if data[index_3d] ~= c_air then
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
		--vm:set_lighting({day = 0, night = 0})

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

