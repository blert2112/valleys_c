-------------------
-- Conifer Trees --
-------------------

-- Create different colored needles with the same properties.
newnode = valc.clone_node("default:pine_needles")
if valc.noleafdecay then
	newnode.groups.leafdecay = 0
end
newnode.tiles = {"default_pine_needles.png^[colorize:#FF0000:15"}
minetest.register_node("valleys_c:pine_needles2", newnode)
newnode.tiles = {"default_pine_needles.png^[colorize:#FFFF00:15"}
minetest.register_node("valleys_c:pine_needles3", newnode)
newnode.tiles = {"default_pine_needles.png^[colorize:#00FF00:15"}
minetest.register_node("valleys_c:pine_needles4", newnode)

if valc.glow then
	minetest.register_node("valleys_c:pine_tree_glowing_moss", {
		description = "Pine tree with glowing moss",
		tiles = {"default_pine_tree_top.png", "default_pine_tree_top.png",
		"default_pine_tree.png^trunks_moss.png"},
		paramtype2 = "facedir",
		is_ground_content = false,
		light_source = 4,
		drop = 'default:pine_tree',
		groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
		sounds = default.node_sound_wood_defaults(),

		on_place = minetest.rotate_node
	})
end


-- similar to the general tree schematic, but basically vertical
function valc.generate_conifer_schematic(trunk_height, radius, trunk, leaf)
	local height = trunk_height + radius * 3 + 1
	local width = 2 * radius + 1
	local trunk_top = height - radius - 1
	local s = valc.schematic_array(width, height, width)

	-- the main trunk
	local probs = {200,150,100,75,50,25}
	for z = -radius,radius do
		for y = 0,trunk_top do
			-- Gives it a vaguely conical shape.
			local r1 = math.ceil((height - y) / 4)
			-- But rounded at the bottom.
			if y == trunk_height + 1 then
				r1 = r1 -1 
			end

			for x = -radius,radius do
				local i = (z+radius)*width*height + y*width + (x+radius) + 1
				local dist = math.round(math.sqrt(x^2 + z^2))
				if x == 0 and z == 0 then
					if trunk == "default:pine_tree" and valc.glow and math.random(10) == 1 then
						s.data[i].name = "valleys_c:pine_tree_glowing_moss"
					else
						s.data[i].name = trunk
					end
					s.data[i].param1 = 255
				elseif y > trunk_height and dist <= r1 then
					s.data[i].name = leaf
					s.data[i].param1 = probs[dist]
				end
			end
		end
	end

	-- leaves at the top
	for z = -1,1 do
		for y = trunk_top, height-1 do
			for x = -1,1 do
				local i = (z+radius)*width*height + y*width + (x+radius) + 1
				if (x == 0 and z == 0) or y < height - 1 then
					s.data[i].name = leaf
					if x == 0 and z == 0 then
						s.data[i].param1 = 255
					else
						s.data[i].param1 = 200
					end
				end
			end
		end
	end

	return s
end

-- generic conifers
valc.schematics.conifer_trees = {}
leaves = {"default:pine_needles", "valleys_c:pine_needles2", "valleys_c:pine_needles3", "valleys_c:pine_needles4"}
for i = 1,#leaves do
	local max_r = 4
	for r = 2,max_r do
		local schem = valc.generate_conifer_schematic(2, r, "default:pine_tree", leaves[i])

		push(valc.schematics.conifer_trees, schem)

		minetest.register_decoration({
			deco_type = "schematic",
			sidelen = 80,
			place_on = {"default:dirt_with_grass",},
			fill_ratio = (max_r-r+1)/500,
			biomes = {"coniferous_forest",},
			schematic = schem,
			flags = "place_center_x, place_center_z",
			rotation = "random",
		})
	end
end

-- Place the schematic when a sapling grows.
function default.grow_new_pine_tree(pos, bad)
	local schem = valc.schematics.conifer_trees[math.random(1,#valc.schematics.conifer_trees)]
	local adj = {x = pos.x - math.floor(schem.size.x / 2),
	             y = pos.y - 1,
	             z = pos.z - math.floor(schem.size.z / 2)}
	minetest.place_schematic(adj, schem, 'random', nil, true)
end

