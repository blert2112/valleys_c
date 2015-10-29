----------------------
-- Decorative Rocks --
----------------------

-- I'm feeling a bit zen...

-- Create a simple sphereoid from nodeboxes.
local function step_sphere(grid, pos, diameters, embed)
	local step = {x=diameters.x * 0.2, y=diameters.y * 0.2, z=diameters.z * 0.2}
	local rock = {}

	if embed then
		embed = 1
	else
		embed = 0
	end

	rock[1] = pos.x + step.x
	rock[2] = pos.y + (step.y * embed)
	rock[3] = pos.z
	rock[4] = pos.x + diameters.x - step.x
	rock[5] = diameters.y + pos.y - step.y - (step.y * embed)
	rock[6] = pos.z + diameters.z
	push(grid, rock)

	rock = {}
	rock[1] = pos.x
	rock[2] = pos.y + (step.y * embed)
	rock[3] = pos.z + step.z
	rock[4] = pos.x + step.x
	rock[5] = diameters.y + pos.y - step.y - (step.y * embed)
	rock[6] = pos.z + diameters.z - step.z
	push(grid, rock)

	rock = {}
	rock[1] = pos.x + diameters.x - step.x
	rock[2] = pos.y + (step.y * embed)
	rock[3] = pos.z + step.z
	rock[4] = pos.x + diameters.x
	rock[5] = diameters.y + pos.y - step.y - (step.y * embed)
	rock[6] = pos.z + diameters.z - step.z
	push(grid, rock)

	if not embed then
		rock = {}
		rock[1] = pos.x + step.x
		rock[2] = pos.y
		rock[3] = pos.z + step.z
		rock[4] = pos.x + diameters.x - step.x
		rock[5] = step.y + pos.y
		rock[6] = pos.z + diameters.z - step.z
		push(grid, rock)
	end

	rock = {}
	rock[1] = pos.x + step.x
	rock[2] = diameters.y + pos.y - step.y - (step.y * embed)
	rock[3] = pos.z + step.z
	rock[4] = pos.x + diameters.x - step.x
	rock[5] = diameters.y + pos.y - (step.y * embed)
	rock[6] = pos.z + diameters.z - step.z
	push(grid, rock)
end


-- Create some tiles of small rocks that can be picked up.
do
	local default_grid
	local tiles = {"default_stone.png", "default_desert_stone.png", "default_sandstone.png"}

	for grid_count = 1,6 do
		local grid = {}
		for rock_count = 2, math.random(4) do
			local diameter = math.random(5,15)/100
			local x = math.random(80)/100 - 0.5
			local z = math.random(80)/100 - 0.5
			step_sphere(grid, {x=x,y=-0.5,z=z}, {x=diameter, y=diameter, z=diameter})
		end

		--local stone = tiles[math.random(#tiles)]
		local stone = tiles[(grid_count % #tiles) + 1]

		minetest.register_node("valleys_c:small_rocks"..grid_count, {
			description = "Small Rocks",
			tiles = {stone},
			is_ground_content = true,
			walkable = false,
			paramtype = "light",
			drawtype = "nodebox",
			node_box = { type = "fixed", 
			             fixed = grid },
			selection_box = { type = "fixed", 
												fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
											},
			groups = {stone=1, oddly_breakable_by_hand=3},
			drop = "valleys_c:small_rocks",
			sounds = default.node_sound_stone_defaults(),
		})

		minetest.register_decoration({
			deco_type = "simple",
			decoration = "valleys_c:small_rocks"..grid_count,
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass", "default:dirt", "default:sand"},
			fill_ratio = 0.002,
			biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest",},
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})

		default_grid = grid
	end

	-- This is the inventory item, so we don't have six different stacks.
	minetest.register_node("valleys_c:small_rocks", {
		description = "Small Rocks",
		tiles = {"default_stone.png"},
		inventory_image = "vmg_small_rocks.png",
		is_ground_content = true,
		walkable = false,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = { type = "fixed", 
								 fixed = default_grid },
		selection_box = { type = "fixed", 
											fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
										},
		groups = {stone=1, oddly_breakable_by_hand=3},
		sounds = default.node_sound_stone_defaults(),
	})
end


-- Create some larger rocks that can be mined.
do
	local tiles = {"default_stone.png", "default_desert_stone.png", "default_sandstone.png"}
	local sel = {{-0.4,-0.5,-0.4,0.4,0.0,0.3}, {-0.4,-0.5,-0.4,0.2,-0.1,0.3}, {-0.3,-0.5,-0.3,0.2,-0.2,0.3}}

	for count = 1,9 do
		local stone = tiles[(count % #tiles) + 1]

		minetest.register_node("valleys_c:medium_rock"..count, {
			description = "Medium Rock",
			tiles = {stone},
			is_ground_content = true,
			walkable = true,
			paramtype = "light",
			drawtype = "mesh",
			mesh = "rock0"..math.ceil(count / 3)..".b3d",
			selection_box = {type="fixed", fixed=sel[math.ceil(count / 3)]},
			groups = {stone=1, cracky=3},
			drop = "default:cobble",
			sounds = default.node_sound_stone_defaults(),
		})

		minetest.register_decoration({
			deco_type = "simple",
			decoration = "valleys_c:medium_rock"..count,
			sidelen = 80,
			place_on = {"default:dirt_with_grass", "default:dirt_with_dry_grass", "default:dirt", "default:sand"},
			fill_ratio = 0.001,
			biomes = {"sandstone_grassland", "tundra", "taiga", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest",},
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end


-- Small rocks can be used to create cobblestone, if you like.
minetest.register_craft({
	output = "default:cobble",
	recipe = {
		{"", "", ""},
		{"valleys_c:small_rocks", "valleys_c:small_rocks", ""},
		{"valleys_c:small_rocks", "valleys_c:small_rocks", ""},
	},
})

