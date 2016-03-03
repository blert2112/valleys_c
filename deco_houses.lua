
--

local newnode = valc.clone_node("default:wood")
newnode.tiles = {"default_wood.png^[colorize:#9F0000:150"}
newnode.drop = "default:wood",
minetest.register_node("valleys_c:wood_red", newnode)
newnode = valc.clone_node("default:wood")
newnode.tiles = {"default_wood.png^[colorize:#009F00:150"}
newnode.drop = "default:wood",
minetest.register_node("valleys_c:wood_green", newnode)
newnode = valc.clone_node("default:wood")
newnode.tiles = {"default_wood.png^[colorize:#00009F:150"}
newnode.drop = "default:wood",
minetest.register_node("valleys_c:wood_blue", newnode)

local max_h = 8

function valc.generate_test_house_schematic(size, floor, walls, ceiling)
	local offset = {x=0,y=0,z=0}
	local width = size.x + 2 * offset.x
	local height = size.y + offset.y
	local depth = size.z + 2 * offset.z + 1
	local s = valc.schematic_array(width, height, depth)

	for z = 0,depth-1 do
		for y = 0,height-1 do
			for x = 0,width-1 do
				local i = z*width*height + y*width + x + 1
				local c = math.floor(width/2)
				local p = math.min(height - 1, math.max(4, height - math.abs(c - x)))

				local p_prev = math.min(height - 1, math.max(4, height - math.abs(c - (x - 1))))
				if x == 0 then
					p_prev = 0
				end

				local p_next = math.min(height - 1, math.max(4, height - math.abs(c - (x + 1))))
				if x == width-1 then
					p_next = 0
				end

				if y <= offset.y then
					if floor == "default:dirt" and z == 0 then
						s.data[i].name = "default:dirt_with_grass"
					else
						s.data[i].name = floor
					end
					s.data[i].param1 = 255
					s.data[i].force_place = true
				elseif (x == offset.x or x == width - offset.x - 1 or z == offset.z + 1 or z == depth - offset.z - 1) and y >= offset.y and y < p and z >= offset.z + 1 and x >= offset.x and x <= width - offset.x - 1 and z <= depth - offset.z - 1 then
					if x == c and y == offset.y + 1 and z == offset.z + 1 then
						s.data[i].name = "doors:door_wood_b"
						s.data[i].param1 = 255
						s.data[i].param2 = 0
						s.data[i].force_place = true
					elseif x == c and y == offset.y + 2 and z == offset.z + 1 then
						s.data[i].name = "air"
						s.data[i].param1 = 255
						s.data[i].param2 = 0
						s.data[i].force_place = true
					elseif y == offset.y + 2 and ((x > offset.x and x < width - offset.x - 1) or (z > offset.z + 1 and z < depth - offset.z - 1)) then
						s.data[i].name = walls
						s.data[i].param1 = 150
						s.data[i].force_place = true
					else
						s.data[i].name = walls
						s.data[i].param1 = 255
						s.data[i].force_place = true
					end
				elseif y == p and z >= offset.z + 1 and x >= offset.x and x <= width - offset.x - 1 and z <= depth - offset.z - 1 then
					if ((x < c and p ~= p_prev) or (x > c and p ~= p_next)) and ceiling == "farming:straw" then
						s.data[i].name = "stairs:stair_straw"
						if x > c then
							s.data[i].param2 = 3
						else
							s.data[i].param2 = 1
						end
					else
						s.data[i].name = ceiling
					end
					s.data[i].param1 = 255
					s.data[i].force_place = true
				elseif z == offset.z and x == c and y == offset.y + 3 then
					s.data[i].name = "default:torch"
					s.data[i].param1 = 125
					s.data[i].param2 = 4
					s.data[i].force_place = true
				else
					s.data[i].name = "air"
					s.data[i].param1 = 255
					s.data[i].force_place = true
				end
			end
		end
	end

	return s
end


valc.schematics.houses = {}
do
	local colors = {"red", "green", "blue"}
	for color = 1,#colors do
		for h = 4,max_h do
			local schem = valc.generate_test_house_schematic({x=h,y=h,z=h}, "default:dirt", "valleys_c:wood_"..colors[color], "farming:straw")

			push(valc.schematics.houses, schem)

			minetest.register_decoration({
				deco_type = "schematic",
				sidelen = 80,
				place_on = {"group:soil"},
				-- noise_params = {
				-- 	offset = -0.9,
				-- 	scale = 1.0,
				-- 	spread = {x = 400, y = 400, z = 400},
				-- 	seed = 37248,
				-- 	octaves = 5,
				-- 	persist = 5.0
				-- },
				fill_ratio = 1/500000,
				biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna",},
				schematic = schem,
				flags = "place_center_x, place_center_z, force_placement",
				rotation = "random",
			})
		end
	end
end

valc.house_replacements = {["default:leaves"] = "air", ["valleys_c:leaves2"] = "air", ["valleys_c:leaves3"] = "air", ["valleys_c:leaves4"] = "air", ["valleys_c:leaves5"] = "air", ["default:pine_needles"] = "air", ["valleys_c:pine_needles2"] = "air", ["valleys_c:pine_needles3"] = "air", ["valleys_c:pine_needles4"] = "air", }
