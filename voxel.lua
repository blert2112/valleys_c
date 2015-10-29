----------------------
-- Voxel Manip Loop --
----------------------

-- This is only used to handle cases the decoration manager can't,
--  such as water plants and cave decorations.


-- the mapgen function
function valc.generate(minp, maxp, seed)
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

	local c_mushroom_fertile_brown = minetest.get_content_id("flowers:mushroom_fertile_brown")
	local c_mushroom_fertile_red = minetest.get_content_id("flowers:mushroom_fertile_red")
	local c_huge_mushroom_cap = minetest.get_content_id("valleys_c:huge_mushroom_cap")
	local c_giant_mushroom_cap = minetest.get_content_id("valleys_c:giant_mushroom_cap")
	local c_giant_mushroom_stem = minetest.get_content_id("valleys_c:giant_mushroom_stem")
	local c_glowing_fungal_stone = minetest.get_content_id("valleys_c:glowing_fungal_stone")
	local c_stalactite = minetest.get_content_id("valleys_c:stalactite")
	local c_stalagmite = minetest.get_content_id("valleys_c:stalagmite")
	local c_sand_with_rocks = minetest.get_content_id("valleys_c:sand_with_rocks")

	-- Air and Ignore
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")

	-- Create a table of biome ids, so I can use the biomemap.
	valc.biome_ids = {}
	local biome_desc = {}
	for name, desc in pairs(minetest.registered_biomes) do
		local i = minetest.get_biome_id(desc.name)
		valc.biome_ids[i] = desc.name
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
						-- Place small rocks for decoration. The actual small rocks
						--  nodes would leave a bubble, so we just use a different tile.
						if math.random(4) == 1 then
							data[ivm] = c_sand_with_rocks
						else
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
											end
										end
									end
								end
							end
						end
					end
				end

				-- Are we underground?
				if y < -1 or data[ivm] == c_stone then
					underground = true
				end

				-- Decorate any open, underground spaces with stone or dirt
				-- This seems to exclude dungeons, which is good.
				if underground and data[ivm] == c_stone or data[ivm] == c_dirt then
					local r = math.random(50)

					-- Plant mushrooms and speleothems.
					if air_count > 0 and r == 1 then
						data[ivm + ystride] = c_mushroom_fertile_red
						data[ivm] = c_dirt
					elseif air_count > 0 and r == 2 then
						data[ivm + ystride] = c_mushroom_fertile_brown
						data[ivm] = c_dirt
					elseif air_count > 1 and r == 4 then
						data[ivm + ystride*2] = c_huge_mushroom_cap
						data[ivm + ystride] = c_giant_mushroom_stem
						data[ivm] = c_dirt
					elseif air_count > 2 and r == 5 then
						data[ivm + ystride*3] = c_giant_mushroom_cap
						data[ivm + ystride*2] = c_giant_mushroom_stem
						data[ivm + ystride] = c_giant_mushroom_stem
						data[ivm] = c_dirt
					elseif air_count > 0 and r <18 then
						data[ivm + ystride] = c_stalagmite
					end

					air_count = 0
				elseif underground and data[ivm] == c_air then
					-- This is how we look for ceiling voxels.
					air_count = air_count + 1
					if air_count == 1 and y < maxp.y and data[ivm + ystride] == c_stone then
						local r = math.random(20)
						if r == 1 then
							data[ivm + ystride] = c_glowing_fungal_stone
						elseif r < 5 then
							data[ivm] = c_stalactite
						end
					end
				else
					air_count = 0
				end
			end
		end
	end

	-- execute voxelmanip boring stuff to write to the map...
	vm:set_data(data)

	-- probably not necessary
	--vm:set_lighting({day = 0, night = 0})

	-- This seems to be necessary to avoid lighting problems.
	vm:calc_lighting()

	-- probably not necessary
	--vm:update_liquids()

	vm:write_to_map()
end

