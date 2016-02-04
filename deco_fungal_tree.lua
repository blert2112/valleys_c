-------------------
-- Fungal Tree   --
-------------------

local colors = {"^[colorize:#FF00FF:60", "", "^[colorize:#0000FF:60", "^[colorize:#FF4500:80"}
valc.fungal_tree_leaves = {}

-- multicolored growths
local count = 0
for _, color in pairs(colors) do
	count = count + 1
	local name = "valleys_c:fungal_tree_leaves_"..count
	valc.fungal_tree_leaves[#valc.fungal_tree_leaves+1] = name

	minetest.register_node(name, {
		description = "Fungal tree growths",
		drawtype = "allfaces_optional",
		waving = 1,
		visual_scale = 1.3,
		tiles = {"valc_fungal_tree_leaves.png"..color},
		paramtype = "light",
		is_ground_content = false,
		groups = {snappy=3, flammable=2, leaves=1, plant=1},
		drop = {
			max_items = 1,
			items = {
				--{items = {"valleys_c:"..tree.name.."_sapling"}, rarity = tree.drop_rarity },
				{items = {name} }
			}
		},
		sounds = default.node_sound_leaves_defaults(),
		after_place_node = default.after_place_leaves,
	})

	minetest.register_craft({
		output = "default:stick",
		recipe = {
			{name}
		}
	})
end

minetest.register_node("valleys_c:fungal_tree_fruit", {
	description = "Fungal tree fruit",
	drawtype = "plantlike",
	visual_scale = 0.75,
	tiles = {"valc_fungal_tree_fruit.png"},
	--inventory_image = ".png",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 6,
	walkable = false,
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {fleshy = 3, dig_immediate = 3, flammable = 2},
	--on_use = minetest.item_eat(2),
	sounds = default.node_sound_leaves_defaults(),
})


-- all leaves
function valc.make_fungal_tree(data, area, pos, height, leaves, fruit)
	for y = 0, height do
		local radius = 1
		if y > 1 and y < height - 2 then
			radius = 2
		end
		local force_x = math.random(3) - 2
		local force_y = math.random(3) - 2
		for z = -radius,radius do
			for x = -radius,radius do
				local sr = math.random(9)
				local i = pos + z*area.zstride + y*area.ystride + x
				if force_x == x and force_y == y then
					data[i] = leaves
				elseif sr == 1 then
					data[i] = fruit
				elseif sr < 6 then
					data[i] = leaves
				end
			end
		end
	end
end
