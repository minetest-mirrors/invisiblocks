---
--- Variables and Settings
---

local S = minetest.get_translator("invisiblocks")
local def = minetest.get_modpath("default") and true
local recipes = minetest.settings:get_bool("invisiblocks.hide_recipes") ~= true

---
--- Nodes
---

local helper = "invisiblocks_block.png^[multiply:#ff000070"

-- Invisible Barrier
minetest.register_node("invisiblocks:barrier", {
	description = S("Invisible Barrier Block"),
	drawtype = "airlike",
	inventory_image = helper,
	wield_image = helper,
	paramtype = "light",
	sunlight_propagates = true,
	sounds = def and default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3}
})

helper = "invisiblocks_block.png^[multiply:#ffff0070"

-- Invisible Light
minetest.register_node("invisiblocks:light", {
	description = S("Invisible Light Source"),
	drawtype = "airlike",
	inventory_image = helper,
	wield_image = helper,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 14,
	sounds = def and default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	}
})

helper = "invisiblocks_block.png^[multiply:#00ff0070"

-- Invisible Mob Wall
minetest.register_node("invisiblocks:mob_wall", {
	description = S("Invisible Mob Wall"),
	drawtype = "airlike",
	inventory_image = helper,
	wield_image = helper,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	sounds = def and default.node_sound_glass_defaults(),
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	}
})

---
--- Recipes
---

if recipes and def then

	minetest.register_craft({
		output = "invisiblocks:barrier 8",
		recipe = {
			{"default:glass", "default:stone", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
		}
	})

	minetest.register_craft({
		output = "invisiblocks:light 8",
		recipe = {
			{"default:glass", "default:meselamp", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
		}
	})

	minetest.register_craft({
		output = "invisiblocks:mob_wall",
		recipe = {
			{"default:glass", "group:wood", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
			{"default:glass", "default:glass", "default:glass"},
		}
	})

	minetest.register_craft({
		output = "invisiblocks:show_stick",
		recipe = {
			{"invisiblocks:barrier"},
			{"group:stick"},
		}
	})
end

---
--- Tools
---

local function show_blocks(list, icon)

	if not list or #list == 0 then return end

	for n = 1, #list do

		minetest.add_particle({
			pos = list[n],
			velocity = {x = 0, y = 0, z = 0},
			acceleration = {x = 0, y = 0, z = 0},
			expirationtime = 10,
			size = 4,
			collisiondetection = false,
			vertical = false,
			texture = icon,
			glow = 5
		})
	end
end

minetest.register_tool("invisiblocks:show_stick", {
	description = S("Show Stick"),
	inventory_image = "invisiblocks_stick.png",
	stack_max = 1,
	groups = {not_in_creative_inventory = 1, stick = 1},

	on_use = function(itemstack, user, pointed_thing)

		local pos = user:get_pos()

		local list = minetest.find_nodes_in_area(
			{x = pos.x - 10, y = pos.y - 10, z = pos.z - 10},
			{x = pos.x + 10, y = pos.y + 10, z = pos.z + 10},
			{"invisiblocks:barrier"})

		show_blocks(list, "invisiblocks_barrier.png")

		list = minetest.find_nodes_in_area(
			{x = pos.x - 10, y = pos.y - 10, z = pos.z - 10},
			{x = pos.x + 10, y = pos.y + 10, z = pos.z + 10},
			{"invisiblocks:light"})

		show_blocks(list, "invisiblocks_light.png")

		list = minetest.find_nodes_in_area(
			{x = pos.x - 10, y = pos.y - 10, z = pos.z - 10},
			{x = pos.x + 10, y = pos.y + 10, z = pos.z + 10},
			{"invisiblocks:mob_wall"})

		show_blocks(list, "invisiblocks_mob_wall.png")

		if not minetest.is_creative_enabled(user:get_player_name()) then
			itemstack:add_wear(65535 / 100) -- 100 uses
		end

		return itemstack
	end
})
