----------------------
-- Flowers / Plants --
----------------------

-- See textures/image-credits.txt

valc.water_plants = {}
function valc.register_water_plant(desc)
	push(valc.water_plants, desc)
end


valc.plantlist = {
	{name="arrow_arum",
	 desc="Arrow Arum",
	 water=true,
	 wave=true,
	 group="plantnodye",
	},

	{name="bird_of_paradise",
	 desc="Bird of Paradise",
	 light=true,
	 group="flowernodye",
	},

	{name="calla_lily",
	 desc="Calla Lily",
	 wave=true,
	 light=true,
	 group="flowerwhitedye",
	},

	{name="gerbera",
	 desc="Gerbera",
	 light=true,
	 group="flowerpinkdye",
	},

	{name="hibiscus",
	 desc="Hibiscus",
	 wave=true,
	 group="flowerwhitedye",
	},

	{name="orchid",
	 desc="Orchid",
	 wave=true,
	 light=true,
	 group="flowerwhitedye",
	},
}


for _, plant in ipairs(valc.plantlist) do
	groups = {snappy=3,flammable=2,flora=1,attached_node=1}
	if plant.group == "flowernodye" then
		groups.flower = 1
	elseif plant.group == "flowerpinkdye" then
		groups.flower = 1
		groups.color_pink = 1
	elseif plant.group == "flowerwhitedye" then
		groups.flower = 1
		groups.color_white = 1
	end

	minetest.register_node("valleys_c:"..plant.name, {
		description = plant.desc,
		drawtype = "plantlike",
		tiles = {"vmg_"..plant.name..".png"},
		inventory_image = "vmg_"..plant.name..".png",
		waving = plant.wave,
		sunlight_propagates = plant.light,
		paramtype = "light",
		walkable = false,
		groups = groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})

	if plant.water then
		local def = {
			description = plant.desc,
			drawtype = "nodebox",
			node_box = {type='fixed', fixed={{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, {-0.5, 0.5, -0.001, 0.5, 1.5, 0.001}, {-0.001, 0.5, -0.5, 0.001, 1.5, 0.5}}},
			drop = {max_items=2, items={{items={"valleys_c:"..plant.name}, rarity=1}, {items={"default:sand"}, rarity=1}}},
			tiles = { "default_sand.png", "vmg_"..plant.name..".png",},
			--tiles = { "default_dirt.png", "vmg_"..plant.name..".png",},
			sunlight_propagates = plant.light,
			--light_source = 14,
			paramtype = "light",
			walkable = false,
			groups = groups,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, 0.5, -0.5, 0.5, 11/16, 0.5},
			},
			sounds = default.node_sound_leaves_defaults(),
		}
		minetest.register_node("valleys_c:"..plant.name.."_water_sand", def)
		def2 = table.copy(def)
		def2.tiles = { "default_dirt.png", "vmg_"..plant.name..".png",}
		def2.drop = {max_items=2, items={{items={"valleys_c:"..plant.name}, rarity=1}, {items={"default:dirt"}, rarity=1}}}
		minetest.register_node("valleys_c:"..plant.name.."_water_soil", def2)
	end
end


local function register_flower(name, seed, biomes)
	local param = {
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.02,
			scale = 0.03,
			spread = {x = 200, y = 200, z = 200},
			seed = seed,
			octaves = 3,
			persist = 0.6
		},
		biomes = biomes,
		y_min = 6,
		y_max = 31000,
		decoration = "valleys_c:"..name,
	}

	-- Let rainforest plants show up more often.
	local key1 = table.contains(biomes, "rainforest")
	local key2 = table.contains(biomes, "desertstone_grassland")
	if key1 or key2 then
		if key1 then
			table.remove(param.biomes, key1)
		else
			table.remove(param.biomes, key2)
		end
		if #param.biomes > 0 then
			minetest.register_decoration(param)
		end

		local param2 = table.copy(param)
		param2.biomes = {"rainforest", "desertstone_grassland", }
		param2.noise_params.seed = param2.noise_params.seed + 20
		param2.noise_params.offset = param2.noise_params.offset + 0.01
		minetest.register_decoration(param2)
	else
		minetest.register_decoration(param)
	end
end

register_flower("bird_of_paradise", 8402, {"rainforest", "desertstone_grassland", })
register_flower("orchid", 3944, {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", })
register_flower("hibiscus", 7831, {"sandstone_grassland", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", })
register_flower("calla_lily", 7985, {"sandstone_grassland", "stone_grassland", "deciduous_forest", "rainforest", "desertstone_grassland", })
register_flower("gerbera", 1976, {"savanna", "rainforest", "desertstone_grassland", })

do
	-- Water Plant: Arrow Arum
	local arrow_def_sand = {
		fill_ratio = 0.05,
		place_on = {"group:sand"},
		decoration = {"valleys_c:arrow_arum_water_sand",},
		--biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", },
		biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp","sandstone_grassland_ocean", "stone_grassland_ocean", "coniferous_forest_ocean", "deciduous_forest_ocean", "desert_ocean", "savanna_ocean", "desertstone_grassland", },
		y_max = 60,
	}
	local arrow_def_soil = table.copy(arrow_def_sand)
	arrow_def_soil.place_on = {"group:soil"}
	arrow_def_soil.decoration = {"valleys_c:arrow_arum_water_soil",}

	valc.register_water_plant(arrow_def_sand)
	valc.register_water_plant(arrow_def_soil)
end


if valc.glow then
	minetest.register_node("valleys_c:moon_weed", {
		description = "Moon Weed",
		drawtype = "plantlike",
		tiles = {"vmg_moon_weed.png"},
		inventory_image = "vmg_moon_weed.png",
		waving = false,
		sunlight_propagates = true,
		paramtype = "light",
		light_source = 8,
		walkable = false,
		groups = {snappy=3,flammable=2,flora=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})

	local param = {
		deco_type = "simple",
		place_on = {"default:dirt_with_grass"},
		sidelen = 80,
		biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp", "desertstone_grassland", },
		fill_ratio = 1/1000,
		y_min = 6,
		y_max = 31000,
		decoration = "valleys_c:moon_weed",
	}
	minetest.register_decoration(param)
end
