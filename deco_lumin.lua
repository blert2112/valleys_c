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

if false then
local newnode = valc.clone_node("default:leaves")
if valc.noleafdecay then
	newnode.groups.leafdecay = 0
end
newnode.tiles = {"default_leaves.png^[brighten"}
newnode.light_source = 15
newnode.drawtype = "normal"
newnode.waving = nil
newnode.special_tiles = nil
minetest.register_node("valleys_c:leaves_lumin", newnode)
end

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
	end

	for x = -1,1 do
		for y = 3, height-1 do
			for z = -1,1 do
				local i = (x+radius)*width*height + y*width + (z+radius) + 1
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
			--biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp",},
			biomes = {"coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

if false then
-- Place the schematic when a sapling grows.
function default.grow_new_apple_tree(pos, bad)
	local schem = valc.schematics.deciduous_trees[math.random(1,#valc.schematics.deciduous_trees)]
	local adj = {x = pos.x - math.floor(schem.size.x / 2),
	             y = pos.y - 1,
	             z = pos.z - math.floor(schem.size.z / 2)}
	minetest.place_schematic(adj, schem, 'random', nil, true)
end

-- Cherries
valc.schematics.cherry_trees = {}
do
	local max_r = 3
	local fruit = nil

	for r = 2,max_r do
		local schem = valc.generate_tree_schematic(2, {x=r, y=r, z=r}, "valleys_c:cherry_blossom_tree", "valleys_c:cherry_blossom_leaves", fruit)

		push(valc.schematics.cherry_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			y_min = 4,
			fill_ratio = (max_r-r+1)/5000,
			biomes = {"deciduous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Birch trees
valc.schematics.birch_trees = {}
do
	local max_h = 4

	for h = 2,max_h do
		local schem = valc.generate_tree_schematic(h, {x=2, y=3, z=2}, "valleys_c:birch_tree", "valleys_c:birch_leaves")

		push(valc.schematics.birch_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
			y_min = 4,
			fill_ratio = (max_h-h+1)/3000,
			biomes = {"deciduous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end
end
