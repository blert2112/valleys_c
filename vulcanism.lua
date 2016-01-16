
local newnode = valc.clone_node("default:stone")
newnode.description = "Lava Stone"
newnode.tiles = {"default_stone.png^[colorize:#000000:80"}
minetest.register_node("valleys_c:lava_stone", newnode)


default.cool_lava_flowing = function(pos)
	local sr = math.random(200)
	if sr == 1 then
		minetest.place_node(pos, {name='default:stone_with_mese'})
	elseif sr == 2 then
		minetest.place_node(pos, {name='default:stone_with_gold'})
	elseif sr == 3 then
		minetest.place_node(pos, {name='default:stone_with_iron'})
	elseif sr == 4 then
		minetest.place_node(pos, {name='default:stone_with_copper'})
	elseif sr < 8 then
		minetest.place_node(pos, {name='default:obsidian'})
	else
		minetest.place_node(pos, {name='valleys_c:lava_stone'})
	end

	minetest.sound_play("default_cool_lava",
		{pos = pos, max_hear_distance = 16, gain = 0.25})
end
 

if false then
minetest.register_abm({
	nodenames = {'default:lava_source'},
	interval = 60,
	chance = 5,
	action = function(pos, node)
		if pos.y > 0 then
			if math.random(8) < 8 then
				local pos2 = {}
				pos2.x = pos.x + math.random(-1,1)
				pos2.y = pos.y + 1
				pos2.z = pos.z + math.random(-1,1)
				minetest.place_node(pos2, {name='default:lava_source'})
			else
				minetest.place_node(pos, {name='default:obsidian'})
			end
		end
	end
})

minetest.register_abm({
	nodenames = {'default:lava_flowing'},
	interval = 30,
	chance = 3,
	action = function(pos, node)
		sr = math.random(500)
		if pos.y > 0 then
			if sr == 1 then
				minetest.place_node(pos, {name='default:stone_with_mese'})
			elseif sr == 2 then
				minetest.place_node(pos, {name='default:stone_with_gold'})
			elseif sr == 3 then
				minetest.place_node(pos, {name='default:stone_with_iron'})
			elseif sr < 7 then
				minetest.place_node(pos, {name='default:obsidian'})
			else
				minetest.place_node(pos, {name='valleys_c:lava_stone'})
			end
		elseif sr < 50 then
			minetest.place_node(pos, {name='default:lava_source'})
		end
	end
})

end
