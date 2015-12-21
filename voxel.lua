----------------------
-- Voxel Manip Loop --
----------------------

-- This is only used to handle cases the decoration manager can't,
--  such as water plants and cave decorations.


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
local c_sand = minetest.get_content_id("default:sand")
local c_sandstone = minetest.get_content_id("default:sandstone")
local c_desertstone = minetest.get_content_id("default:desert_stone")
local c_river_water_source = minetest.get_content_id("default:river_water_source")
local c_water_source = minetest.get_content_id("default:water_source")

local c_sand_with_rocks = minetest.get_content_id("valleys_c:sand_with_rocks")
local c_glowing_sand = minetest.get_content_id("valleys_c:glowing_sand")
local c_fungal_stone = minetest.get_content_id("valleys_c:glowing_fungal_stone")
local c_stalactite = minetest.get_content_id("valleys_c:stalactite")
local c_stalagmite = minetest.get_content_id("valleys_c:stalagmite")
local c_mushroom_cap_giant = minetest.get_content_id("valleys_c:giant_mushroom_cap")
local c_mushroom_cap_huge = minetest.get_content_id("valleys_c:huge_mushroom_cap")
local c_mushroom_stem = minetest.get_content_id("valleys_c:giant_mushroom_stem")
local c_mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red")
local c_mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown")
local c_waterlily = minetest.get_content_id("flowers:waterlily")

-- Air and Ignore
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")

local water_lily_biomes = {"rainforest_swamp", "rainforest", "savanna_swamp", "savanna",  "deciduous_forest_swamp", "deciduous_forest"}

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
	-- local heightmap = minetest.get_mapgen_object("heightmap")
	-- local heatmap = minetest.get_mapgen_object("heatmap")
	local data = vm:get_data() -- data is the original array of content IDs (solely or mostly air)
	-- Be careful: emin ≠ minp and emax ≠ maxp !
	-- The data array is not limited by minp and maxp. It exceeds it by 16 nodes in the 6 directions.
	-- The real limits of data array are emin and emax.
	-- The VoxelArea is used to convert a position into an index for the array.
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local ystride = a.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.
	local zstride = a.zstride

	-- The biomemap is a table of biome index numbers for each horizontal
	--  location. It's created in the mapgen, and is right most of the time.
	--  It's off in about 1% of cases, for various reasons.
	-- Bear in mind that biomes can change from one voxel to the next.
	local biomemap = minetest.get_mapgen_object("biomemap")

	local plant_n = minetest.get_perlin_map({offset = 0.0, scale = 1.0, spread = {x = 200, y = 200, z = 200}, seed = 33, octaves = 3, persist = 0.7, lacunarity = 2.0}, vector.add(vector.subtract(maxp, minp), 1)):get2dMap_flat(minp)

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	-- the mapgen algorithm
	local index_2d = 0
	local write = false
	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local index_3d = a:index(x, maxp.y, z) -- index of the data array, matching the position {x, y, z}
			local underground = false
			local air_count = 0
			index_2d = index_2d + 1

			for y = maxp.y, minp.y, -1 do -- for each node in vertical line
				if (y < 1 and data[index_3d] == c_air) or data[index_3d] == c_stone or data[index_3d] == c_sandstone or data[index_3d] == c_desertstone then
					underground = true
				end

				if data[index_3d] == c_sand then
					local sr = math.random(50)
					if valc.glow and sr == 1 then
						data[index_3d] = c_glowing_sand
						write = true
					elseif sr < 10 then
						data[index_3d] = c_sand_with_rocks
						write = true
					end
				end

				-- Avoid the edges of the chunk, just to make things easier.
				-- Look for river sand (or dirt, just in case).
				if y < maxp.y and x > minp.x and x < maxp.x and z > minp.z and z < maxp.z and (data[index_3d] == c_sand or data[index_3d] == c_dirt) then
					if data[index_3d + ystride] == c_river_water_source or data[index_3d + ystride] == c_water_source then
						-- Check to make sure that a plant root is fully surrounded.
						-- This is due to the kludgy way you have to make water plants
						--  in minetest, to avoid bubbles.
						local surround = true
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
						-- Check the biomes and plant water plants, if called for.
						if surround then
							for _, desc in pairs(valc.water_plants) do
								local placeable = false
								local place = desc.place_on
								if type(place) == 'string' then
									if (place == "default:dirt" and data[index_3d] == c_dirt) or (place == "default:sand" and data[index_3d] == c_sand) then
										placeable = true
									end
								elseif type(place) == 'table' then
									for _, e in pairs(place) do
										if type(e) == 'string' then
											if (e == "default:dirt" and data[index_3d] == c_dirt) or (e == "default:sand" and data[index_3d] == c_sand) then
												placeable = true
											end
										end
									end
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

				if y < maxp.y and data[index_3d] == c_air and data[index_3d + ystride] == c_stone then
					local sr = math.random(20)
					if sr == 1 then
						data[index_3d + ystride] = c_fungal_stone
						write = true
					elseif sr < 5 then
						data[index_3d] = c_stalactite
						write = true
					end
				end

				if y > minp.y and underground and data[index_3d] == c_air then
					air_count = air_count + 1
					if data[index_3d - ystride] == c_stone then
						local sr = math.random(100)
						if sr < 21 then
							data[index_3d] = c_stalagmite
						elseif sr < 24 then
							data[index_3d] = c_mushroom_fertile_red
							data[index_3d - ystride] = c_dirt
							write = true
						elseif sr < 27 then
							data[index_3d] = c_mushroom_fertile_brown
							data[index_3d - ystride] = c_dirt
							write = true
						elseif air_count > 1 and sr < 29 then
							data[index_3d + ystride] = c_mushroom_cap_huge
							data[index_3d] = c_mushroom_stem
							data[index_3d - ystride] = c_dirt
							write = true
						elseif air_count > 2 and sr < 30 then
							data[index_3d + 2 * ystride] = c_mushroom_cap_giant
							data[index_3d + ystride] = c_mushroom_stem
							data[index_3d] = c_mushroom_stem
							data[index_3d - ystride] = c_dirt
							write = true
						elseif sr < 34 then
							data[index_3d - ystride] = c_dirt
							write = true
						end
					end
				end

				if y > minp.y and data[index_3d] == c_air and data[index_3d - ystride] == c_river_water_source then
					local biome = valc.biome_ids[biomemap[index_2d]]
					-- I haven't figured out what the decoration manager is
					--  doing with the noise functions, but this works ok.
					if table.contains(water_lily_biomes, biome) and plant_n[index_2d] > 0.5 and math.random(5) == 1 then
						data[index_3d] = c_waterlily
						write = true
					end
				end

				if data[index_3d] ~= c_air then
					air_count = 0
				end
				index_3d = index_3d - ystride
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
	print("\nValleys_C lua Mapgen Times:")

	average = mean(mapgen_times.liquid_lighting)
	print("  liquid_lighting: - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.loops)
	print("  loops: - - - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.make_chunk)
	print("  makeChunk: - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.noisemaps)
	print("  noisemaps: - - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.preparation)
	print("  preparation: - - - - - - - - - - - - - -  "..average)

	average = mean(mapgen_times.writing)
	print("  writing: - - - - - - - - - - - - - - - -  "..average)

	print()
end)


-- Call the mapgen function valc.generate on mapgen.
--  (located in voxel.lua)
minetest.register_on_generated(valc.generate)

