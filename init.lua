----------------------------------------
-- The Valleys Mapgen C++ Helper Code --
----------------------------------------

-- This code handles standard decorations for the Valleys Mapgen C++
--  mapgen. Most of this code is based on Gael-de-Sailly's amazing
--  work. The C++ mapgen is available at...
--    https://github.com/duane-r/minetest


-- Check for necessary mod functions and abort if they aren't available.
if not minetest.get_biome_id then
	minetest.log()
	minetest.log("* Not loading Valleys Mapgen *")
	minetest.log("Valleys Mapgen requires mod functions which are")
	minetest.log(" not exposed by your Minetest build.")
	minetest.log()
	return
end


-- the mod object
valc = {}
valc.version = "1.0"

valc.noleafdecay = not minetest.setting_getbool('valc_leaf_decay')
valc.glow = minetest.setting_getbool('valc_glow')
valc.houses = minetest.setting_getbool('valc_houses')


-- path to all Valleys Mapgen code
valc.path = minetest.get_modpath("valleys_c")


-- Modify a node to add a group
function minetest.add_group(node, groups)
	local def = minetest.registered_items[node]
	if not def then
		return false
	end
	local def_groups = def.groups or {}
	for group, value in pairs(groups) do
		if value ~= 0 then
			def_groups[group] = value
		else
			def_groups[group] = nil
		end
	end
	minetest.override_item(node, {groups = def_groups})
	return true
end

-- Check if the table contains an element.
function table.contains(table, element)
  for key, value in pairs(table) do
    if value == element then
			if key then
				return key
			else
				return true
			end
    end
  end
  return false
end

-- This isn't already in the math library? Really?
function math.round(i)
	return math.floor(i + 0.5)
end

-- Push an element onto a stack (table).
function push(t, x)
	t[#t+1] = x
end

function valc.clone_node(name)
	local node = minetest.registered_nodes[name]
	local node2 = table.copy(node)
	return node2
end



-- Prevent rivers from flowing through (the air in) caves.
minetest.override_item("default:river_water_source", {is_ground_content = true})


-- Execute each section of the code.
--dofile(valc.path.."/biomes.lua")
dofile(valc.path.."/deco.lua")
dofile(valc.path.."/vulcanism.lua")
dofile(valc.path.."/voxel.lua")

minetest.register_abm({
	nodenames = {"bones:bones"},
	interval = 10,
	chance = 1,
	action = function(pos)
		minetest.log("*** Bones say: I'm at ("..pos.x..","..pos.y..","..pos.z..").")
	end,
})


minetest.log("Valleys Mapgen C++ Helper loaded")

