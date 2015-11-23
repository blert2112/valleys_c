----------------------
-- Cave Decorations --
----------------------

-- Mushrooms and Speleothems
--  These are instantiated by voxel.lua since the decoration manager
--   only works at the surface of the world.

minetest.register_node("valleys_c:huge_mushroom_cap", {
	description = "Huge Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.5, -0.5, -0.33, 0.5, -0.33, 0.33}, 
			{-0.33, -0.5, 0.33, 0.33, -0.33, 0.5}, 
			{-0.33, -0.5, -0.33, 0.33, -0.33, -0.5}, 
			{-0.33, -0.33, -0.33, 0.33, -0.17, 0.33}, 
		} },
	light_source = 4,
	groups = {oddly_breakable_by_hand=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("valleys_c:giant_mushroom_cap", {
	description = "Giant Mushroom Cap",
	tiles = {"vmg_mushroom_giant_cap.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_cap.png"},
	is_ground_content = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.4, -0.5, -0.4, 0.4, 0.0, 0.4},
			{-0.75, -0.5, -0.4, -0.4, -0.25, 0.4},
			{0.4, -0.5, -0.4, 0.75, -0.25, 0.4},
			{-0.4, -0.5, -0.75, 0.4, -0.25, -0.4},
			{-0.4, -0.5, 0.4, 0.4, -0.25, 0.75},
		} },
	light_source = 8,
	groups = {oddly_breakable_by_hand=1, dig_immediate=3, flammable=2, plant=1, leafdecay=1},
})

minetest.register_node("valleys_c:giant_mushroom_stem", {
	description = "Giant Mushroom Stem",
	tiles = {"vmg_mushroom_giant_under.png", "vmg_mushroom_giant_under.png", "vmg_mushroom_giant_stem.png"},
	is_ground_content = false,
	groups = {tree=1,choppy=2,oddly_breakable_by_hand=1,flammable=2, plant=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }},
})

-- Mushroom stems can be used as wood, ala Journey to the Center of the Earth.
minetest.register_craft({
	output = "default:wood",
	recipe = {
		{"valleys_c:giant_mushroom_stem"}
	}
})

-- Caps can be cooked and eaten.
minetest.register_node("valleys_c:mushroom_steak", {
	description = "Mushroom Steak",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_mushroom_steak.png"},
	inventory_image = "vmg_mushroom_steak.png",
	on_use = minetest.item_eat(4),
	groups = {dig_immediate = 3, attached_node = 1},
})

minetest.register_craft({
	type = "cooking",
	output = "valleys_c:mushroom_steak",
	recipe = "valleys_c:huge_mushroom_cap",
	cooktime = 2,
})

minetest.register_craft({
	type = "cooking",
	output = "valleys_c:mushroom_steak 2",
	recipe = "valleys_c:giant_mushroom_cap",
	cooktime = 2,
})

-- Glowing fungal stone provides an eerie light.
minetest.register_node("valleys_c:glowing_fungal_stone", {
	description = "Glowing Fungal Stone",
	tiles = {"default_stone.png^vmg_glowing_fungal.png",},
	is_ground_content = true,
	light_source = 8,
	groups = {cracky=3, stone=1},
	drop = {items={ {items={"default:cobble"},}, {items={"valleys_c:glowing_fungus",},},},},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("valleys_c:glowing_fungus", {
	description = "Glowing Fungus",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_glowing_fungus.png"},
	inventory_image = "vmg_glowing_fungus.png",
	groups = {dig_immediate = 3, attached_node = 1},
})

-- The fungus can be made into juice and then into glowing glass.
minetest.register_node("valleys_c:moon_juice", {
	description = "Moon Juice",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"vmg_moon_juice.png"},
	inventory_image = "vmg_moon_juice.png",
	groups = {dig_immediate = 3, attached_node = 1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("valleys_c:moon_glass", {
	description = "Moon Glass",
	drawtype = "glasslike",
	tiles = {"default_glass.png",},
	inventory_image = minetest.inventorycube("default_glass.png"),
	is_ground_content = true,
	light_source = default.LIGHT_MAX,
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "valleys_c:moon_juice",
	recipe = {
		{"valleys_c:glowing_fungus", "valleys_c:glowing_fungus", "valleys_c:glowing_fungus"},
		{"valleys_c:glowing_fungus", "valleys_c:glowing_fungus", "valleys_c:glowing_fungus"},
		{"valleys_c:glowing_fungus", "vessels:glass_bottle", "valleys_c:glowing_fungus"},
	},
})

minetest.register_craft({
	output = "valleys_c:moon_glass",
	type = "shapeless",
	recipe = {
		"valleys_c:moon_juice",
		"valleys_c:moon_juice",
		"default:glass",
	},
})

-- What's a cave without speleothems?
minetest.register_node("valleys_c:stalactite", {
	description = "Stalactite",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	walkable = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.07, 0.0, -0.07, 0.07, 0.5, 0.07}, 
			{-0.04, -0.25, -0.04, 0.04, 0.0, 0.04}, 
			{-0.02, -0.5, -0.02, 0.02, 0.25, 0.02}, 
		} },
	groups = {stone=1, cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("valleys_c:stalagmite", {
	description = "Stalagmite",
	tiles = {"default_stone.png"},
	is_ground_content = false,
	walkable = false,
	paramtype = "light",
	drawtype = "nodebox",
	node_box = { type = "fixed", 
		fixed = {
			{-0.07, -0.5, -0.07, 0.07, 0.0, 0.07}, 
			{-0.04, 0.0, -0.04, 0.04, 0.25, 0.04}, 
			{-0.02, 0.25, -0.02, 0.02, 0.5, 0.02}, 
		} },
	groups = {stone=1, cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

-- They can be made into cobblestone, to get them out of inventory.
minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"", "", ""},
		{"valleys_c:stalactite", "valleys_c:stalactite", ""},
		{"valleys_c:stalactite", "valleys_c:stalactite", ""},
	},
})

minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"", "", ""},
		{"valleys_c:stalagmite", "valleys_c:stalagmite", ""},
		{"valleys_c:stalagmite", "valleys_c:stalagmite", ""},
	},
})

minetest.register_node("valleys_c:glowing_dirt", {
	description = "Glowing Dirt",
	tiles = {"default_dirt.png"},
	groups = {crumbly = 3, soil = 1},
	light_source = default.LIGHT_MAX,
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "valleys_c:glowing_dirt",
		dry = "valleys_c:glowing_soil",
		wet = "valleys_c:glowing_soil_wet"
	},
})

minetest.register_node("valleys_c:glowing_soil", {
	description = "Glowing Soil",
	tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
	drop = "valleys_c:glowing_dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	light_source = default.LIGHT_MAX,
	soil = {
		base = "valleys_c:glowing_dirt",
		dry = "valleys_c:glowing_soil",
		wet = "valleys_c:glowing_soil_wet"
	},
})

minetest.register_node("valleys_c:glowing_soil_wet", {
	description = "Wet Glowing Soil",
	tiles = {"default_dirt.png^farming_soil_wet.png", "default_dirt.png^farming_soil_wet_side.png"},
	drop = "valleys_c:glowing_dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=3, wet = 1, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	light_source = default.LIGHT_MAX,
	soil = {
		base = "valleys_c:glowing_dirt",
		dry = "valleys_c:glowing_soil",
		wet = "valleys_c:glowing_soil_wet"
	},
})

minetest.register_craft({
	output = "valleys_c:glowing_dirt",
	type = "shapeless",
	recipe = {
		"valleys_c:moon_juice",
		"default:dirt",
	},
})

