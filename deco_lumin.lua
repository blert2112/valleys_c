---------------------
-- Luminous Trees --
---------------------

minetest.register_node("valleys_c:leaves_lumin", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png^[brighten"},
	special_tiles = {"default_leaves_simple.png^[brighten"},
	paramtype = "light",
	is_ground_content = false,
	light_source = 8,
	groups = {snappy = 3, leafdecay = 4, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			--{
			--	-- player will get sapling with 1/20 chance
			--	items = {'default:sapling'},
			--	rarity = 20,
			--},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'valleys_c:leaves_lumin'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

function valc.generate_luminous_schematic(trunk_height)
	local height = trunk_height + 3
	local radius = 1
	local width = 3
	local s = valc.schematic_array(width, height, width)

	-- the main trunk
	for y = 0,trunk_height do
		local i = (0+radius)*width*height + y*width + (0+radius) + 1
		s.data[i].name = "valleys_c:birch_tree"
		s.data[i].param1 = 255
		s.data[i].force_place = true
	end

	for z = -1,1 do
		for y = 3, height-1 do
			for x = -1,1 do
				local i = (z+radius)*width*height + y*width + (x+radius) + 1
				if y > height then
					s.data[i].name = "valleys_c:leaves_lumin"
					if x == 0 and z == 0 then
						s.data[i].param1 = 255
					else
						s.data[i].param1 = 127
					end
				elseif x == 0 and z == 0 then
					s.data[i].name = "valleys_c:leaves_lumin"
					s.data[i].param1 = 255
				elseif x ~= 0 or z ~= 0 then
					s.data[i].name = "valleys_c:leaves_lumin"
					s.data[i].param1 = 127
				end
			end
		end
	end

	return s
end

-- generic luminous trees
valc.schematics.luminous_trees = {}
local leaves = {"valleys_c:leaves_lumin"}
for i = 1,#leaves do
	local max_r = 6
	local fruit = nil

	for r = 3,max_r do
		local schem = valc.generate_luminous_schematic(r)

		push(valc.schematics.luminous_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			y_min = 4,
			fill_ratio = (max_r-r+1)/5000,
			biomes = {"coniferous_forest", "deciduous_forest", "rainforest", "rainforest_swamp",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end
