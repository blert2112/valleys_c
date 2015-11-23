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


-- the mapgen function
function valc.generate(minp, maxp, seed)
	local t0 = os.clock()

	-- minp and maxp strings, used by logs
	local minps, maxps = minetest.pos_to_string(minp), minetest.pos_to_string(maxp)

	-- Define content IDs
	-- A content ID is a number that represents a node in the core of Minetest.
	-- Every nodename has its ID.
	-- The VoxelManipulator uses content IDs instead of nodenames.

	-- Ground nodes
	local c_stone = minetest.get_content_id("default:stone")
	local c_dirt = minetest.get_content_id("default:dirt")
	local c_sand = minetest.get_content_id("default:sand")
	local c_river_water_source = minetest.get_content_id("default:river_water_source")

	local c_sand_with_rocks = minetest.get_content_id("valleys_c:sand_with_rocks")

	-- Air and Ignore
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

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

	-- Mapgen preparation is now finished. Check the timer to know the elapsed time.
	local t1 = os.clock()

	-- the mapgen algorithm
	local map_index = 0
	local write = false
	for x = minp.x, maxp.x do -- for each YZ plane
		for z = minp.z, maxp.z do -- for each vertical line in this plane
			local underground = false
			local air_count = 0
			map_index = map_index + 1

			for y = maxp.y, minp.y, -1 do -- for each node in vertical line
				local ivm = a:index(x, y, z) -- index of the data array, matching the position {x, y, z}
				-- Avoid the edges of the chunk, just to make things easier.
				-- Look for river sand (or dirt, just in case).
				if y < maxp.y and x > minp.x and x < maxp.x and z > minp.z and z < maxp.z and (data[ivm] == c_sand or data[ivm] == c_dirt) then
					-- If there's river water above, it's a river.
					local ivm2 = ivm + ystride
					if data[ivm2] == c_river_water_source then
						-- Check to make sure that a plant root is fully surrounded.
						-- This is due to the kludgy way you have to make water plants
						--  in minetest, to avoid bubbles.
						local surround = true
						for x1 = -1,1,2 do
							local n = data[ivm+x1] 
							if n == c_river_water_source or n == c_air then
								surround = false
							end
						end
						for z1 = -zstride,zstride,2*zstride do
							local n = data[ivm+z1] 
							if n == c_river_water_source or n == c_air then
								surround = false
							end
						end
						-- Check the biomes and plant water plants, if called for.
						if surround then
							for _, desc in pairs(valc.water_plants) do
								if desc.fill_ratio and desc.content_id then
									local biome = valc.biome_ids[biomemap[map_index]]

									if not desc.biomes or (biome and desc.biomes and table.contains(desc.biomes, biome)) then
										if math.random() <= desc.fill_ratio then
											data[ivm] = desc.content_id
											write = true
										end
									end
								end
							end
						end
					end
				end
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
