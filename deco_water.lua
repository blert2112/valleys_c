-- Modified from Perttu Ahola's <celeron55@gmail.com> "noairblocks"
-- mod and released as LGPL 2.1, as the original.


local water_nodes = {"default:water_source", "default:water_flowing", "default:river_water_source",  "default:river_water_flowing"}
local valc_nodes = {"valleys_c:water_source", "valleys_c:water_flowing", "valleys_c:river_water_source",  "valleys_c:river_water_flowing"}

for _, name in pairs(water_nodes) do
	local water = table.copy(minetest.registered_nodes[name])
	local new_name = string.gsub(name, 'default', 'valleys_c')
	local new_source = string.gsub(water.liquid_alternative_source, 'default', 'valleys_c')
	local new_flowing = string.gsub(water.liquid_alternative_flowing, 'default', 'valleys_c')
	water.alpha = 0
	water.liquid_alternative_source = new_source
	water.liquid_alternative_flowing = new_flowing
	water.groups.not_in_creative_inventory = 1

	minetest.register_node(new_name, water)
end


local check_pos = {
	{x=-1, y=0, z=0},
	{x=1, y=0, z=0},
	{x=0, y=0, z=-1},
	{x=0, y=0, z=1},
	{x=0, y=1, z=0},
}

minetest.register_abm({
	nodenames = {"group:sea"},
	neighbors = {"group:water"},
	interval = 10,
	chance = 1,
	action = function(pos)
		for _,offset in pairs(check_pos) do
			local check = vector.add(pos, offset)
			local check_above = vector.add(check, {x=0,y=1,z=0})
			if offset == {0,-1,0} or minetest.get_node(check_above).name ~= "air" then
				local name = minetest.get_node(check).name
				for node_num=1,#water_nodes do
					if name == water_nodes[node_num] then
						minetest.add_node(check, {name = valc_nodes[node_num]})
					end
				end
			end
		end
	end,
})

minetest.register_abm({
	nodenames = valc_nodes,
	neighbors = {"air"},
	interval = 20,
	chance = 1,
	action = function(pos)
		if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name == "air" then
			minetest.remove_node(pos)
		end
	end,
})
