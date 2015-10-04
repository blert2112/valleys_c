----------------------
-- Flowers / Plants --
----------------------

-- See textures/image-credits.txt

vmg.water_plants = {}
function vmg.register_water_plant(desc)
	push(vmg.water_plants, desc)
end


vmg.plantlist = {
	{name="arrow_arum",
	 desc="Arrow Arum",
	 water=true,
	 wave=true,
	 group="plantnodye",
	 selbox={-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}},

	{name="bird_of_paradise",
	 desc="Bird of Paradise",
	 light=true,
	 group="flowernodye",
	 selbox={-0.2, -0.5, -0.2, 0.2, 0.5, 0.2}},

	{name="calla_lily",
	 desc="Calla Lily",
	 wave=true,
	 light=true,
	 group="flowerwhitedye",
	 selbox={{-0.2, -0.3, -0.2, 0.0, 0.5, 0.2},
	         {-0.35, -0.5, -0.35, 0.35, -0.3, 0.35}}},

	{name="gerbera",
	 desc="Gerbera",
	 light=true,
	 group="flowerpinkdye",
	 selbox={-0.15, -0.5, -0.15, 0.15, 0.2, 0.15}},

	{name="hibiscus",
	 desc="Hibiscus",
	 wave=true,
	 group="flowerwhitedye",
	 selbox={-0.35, -0.5, -0.35, 0.35, 0.35, 0.35}},

	{name="orchid",
	 desc="Orchid",
	 wave=true,
	 light=true,
	 group="flowerwhitedye",
	 selbox={-0.3, -0.5, -0.3, 0.2, 0.5, 0.3}},
}


for _, plant in ipairs(vmg.plantlist) do
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
			fixed = plant.selbox,
		},
	})

	if plant.water then
		minetest.register_node("valleys_c:"..plant.name.."_water", {
			description = plant.desc,
			drawtype = "nodebox",
			node_box = {type='fixed', fixed={{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, {-0.5, 0.5, -0.001, 0.5, 1.5, 0.001}, {-0.001, 0.5, -0.5, 0.001, 1.5, 0.5}}},
			drop = "valleys_c:"..plant.name,
			tiles = { "default_sand.png", "vmg_"..plant.name..".png",},
			sunlight_propagates = plant.light,
			paramtype = "light",
			walkable = false,
			groups = groups,
			sounds = default.node_sound_leaves_defaults(),
		})
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
	local key = table.contains(biomes, "rainforest")
	if key then
		table.remove(param.biomes, key)
		if #param.biomes > 0 then
			minetest.register_decoration(param)
		end

		local param2 = table.copy(param)
		param2.biomes = {"rainforest"}
		param2.noise_params.seed = param2.noise_params.seed + 20
		param2.noise_params.offset = param2.noise_params.offset + 0.01
		minetest.register_decoration(param2)
	else
		minetest.register_decoration(param)
	end
end

do
	register_flower("bird_of_paradise", 8402, {"rainforest",})
	register_flower("orchid", 3944, {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp",})
	register_flower("hibiscus", 7831, {"sandstone_grassland", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp",})
	register_flower("calla_lily", 7985, {"sandstone_grassland", "stone_grassland", "deciduous_forest", "rainforest",})
	register_flower("gerbera", 1976, {"savanna", "rainforest",})

	-- Water Plant: Arrow Arum
	vmg.register_water_plant({
		fill_ratio = 0.1,
		decoration = {"valleys_c:arrow_arum_water",},
		biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp",},
		y_max = 60,
	})
end
