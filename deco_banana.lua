-------------------
-- Banana Plants --
-------------------

-- A shock of leaves at the top and some fruit.
function vmg.generate_banana_schematic(trunk_height)
	local height = trunk_height + 3
	local radius = 1
	local width = 3
	local s = vmg.schematic_array(width, height, width)

	-- the main trunk
	for y = 0,trunk_height do
		local i = (0+radius)*width*height + y*width + (0+radius) + 1
		s.data[i].name = "valleys_c:banana_tree"
		s.data[i].param1 = 255
	end

	-- leaves at the top
	for x = -1,1 do
		for y = trunk_height+1, height-1 do
			for z = -1,1 do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
				if y > height - 2 then
					s.data[i].name = "valleys_c:banana_leaves"
					if x == 0 and z == 0 then
						s.data[i].param1 = 255
					else
						s.data[i].param1 = 127
					end
				elseif x == 0 and z == 0 then
					s.data[i].name = "valleys_c:banana_leaves"
					s.data[i].param1 = 255
				elseif x ~= 0 or z ~= 0 then
					s.data[i].name = "valleys_c:banana"
					s.data[i].param1 = 75
				end
			end
		end
	end

	return s
end


-- banana plant (It's not a tree.)
vmg.schematics.banana_plants = {}
do
	local max_h = 4
	for h = 2,max_h do
		local schem = vmg.generate_banana_schematic(h)

		push(vmg.schematics.banana_plants, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass",},
			fill_ratio = (max_h-h+1)/5000,
			biomes = {"rainforest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

