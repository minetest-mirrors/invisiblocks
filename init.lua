
-- == Variables and Settings

local S = core.get_translator(core.get_current_modname())
local def = core.get_modpath("default")
local mcl = core.get_modpath("mcl_core")
local recipes = core.settings:get_bool("invisiblocks.hide_recipes") ~= true
local radius = core.settings:get("invisiblocks.radius") or 10
local delay = core.settings:get("invisiblocks.delay") or 0.5

-- == Sounds

local sound = def and default.node_sound_glass_defaults()
	or mcl and mcl_sounds.node_sound_glass_defaults()

-- == Nodes

local group = {invisible = 1, unbreakable = 1}

-- Barrier
core.register_node("invisiblocks:barrier", {
	description = S("Barrier Block"),
	drawtype = "airlike",
	buildable_to = false,
	inventory_image = "invisiblocks_barrier.png",
	wield_image = "invisiblocks_barrier.png",
	paramtype = "light",
	sunlight_propagates = true,
	sounds = sound,
	groups = group,
	on_blast = function() end
})

-- Light
core.register_node("invisiblocks:light", {
	description = S("Light Source"),
	drawtype = "airlike",
	buildable_to = false,
	inventory_image = "invisiblocks_light.png",
	wield_image = "invisiblocks_light.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 14,
	sounds = sound,
	groups = group,
	selection_box = {
		type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	},
	on_blast = function() end
})

-- Mob Wall
core.register_node("invisiblocks:mob_wall", {
	description = S("Mob Wall"),
	drawtype = "airlike",
	buildable_to = false,
	inventory_image = "invisiblocks_mob_wall.png",
	wield_image = "invisiblocks_mob_wall.png",
	paramtype = "light",
	sunlight_propagates = true,
	sounds = sound,
	groups = group,
	walkable = false,
	_pathfinding_class = "IGNORE", -- mineclonia flag for pathfinding
	selection_box = {
		type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	},
	on_blast = function() end
})

-- == Globalstep

local get_players = core.get_connected_players
local timer = 0
local items = {
	["invisiblocks:barrier"] = "invisiblocks_barrier.png",
	["invisiblocks:light"] =  "invisiblocks_light.png",
	["invisiblocks:mob_wall"] = "invisiblocks_mob_wall.png"}

core.register_globalstep(function(dtime)

	timer = timer + dtime ; if timer < delay then return end ; timer = 0

	for _, player in pairs(get_players()) do

		local name = player:get_player_name()
		local iname = player:get_wielded_item():get_name()

		if items[iname] then

			local pos = player:get_pos()
			local nodes = core.find_nodes_in_area(
					{x = pos.x - radius, y = pos.y - radius, z = pos.z - radius},
					{x = pos.x + radius, y = pos.y + radius, z = pos.z + radius}, iname)

			for _, p in pairs(nodes) do

				core.add_particle({
					pos = p,
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = delay,
					size = 7,
					playername = name,
					texture = items[iname],
					glow = 10
				})
			end
		end
	end
end)

--== Punch Function (only players holding an invisi-node with permission can remove it)

core.register_on_punchnode(function(pos, node, p)

	local iname = p:get_wielded_item():get_name()

	if items[iname] and iname == node.name
	and not core.is_protected(pos, p:get_player_name()) then

		core.node_dig(pos, node, p)

		local def = core.registered_nodes[node.name]

		if def and def.sounds and def.sounds.dug then
			core.sound_play(def.sounds.dug, {pos = pos}, true)
		end
	end
end)

--== Recipes

if recipes then

	local stone = mcl and "mcl_core:stone" or "default:stone"
	local wood = "group:wood"
	local lamp = mcl and "mcl_redstone_torch:redstoneblock" or "default:meselamp"
	local glass = mcl and "mcl_core:glass" or "default:glass"

	core.register_craft({
		output = "invisiblocks:barrier",
		recipe = {
			{glass, glass, glass},
			{glass, stone, glass},
			{glass, glass, glass}
		}
	})

	core.register_craft({
		output = "invisiblocks:light",
		recipe = {
			{glass, glass, glass},
			{glass, lamp, glass},
			{glass, glass, glass}
		}
	})

	core.register_craft({
		output = "invisiblocks:mob_wall",
		recipe = {
			{glass, glass, glass},
			{glass, wood, glass},
			{glass, glass, glass}
		}
	})
end

--== Compatibility

local stick = mcl and "mcl_core:stick" or "default:stick"

core.register_alias("invisiblocks:show_stick", stick)


print("[MOD] Invisiblocks loaded")
