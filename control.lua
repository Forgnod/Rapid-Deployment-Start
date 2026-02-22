-- Initialize global storage for persistent settings
storage.rds_queue = storage.rds_queue or {}
storage.rds_settings = storage.rds_settings or {
    harbinger_range = 100,
    treenocide = false
}

-- This function handles the "Supply Drop" (One by one into inventory)
local function rds_supply_drop(player)
    local inventory = player.get_main_inventory()
    if not inventory then return end

    local items = {
        {name = "mech-armor", count = 1, quality = "rare"},
        {name = "fusion-reactor-equipment", count = 5, quality = "epic"},
        {name = "exoskeleton-equipment", count = 5, quality = "rare"},
        {name = "personal-roboport-mk2-equipment", count = 4, quality = "rare"},
        {name = "energy-shield-mk2-equipment", count = 3, quality = "rare"},
        {name = "battery-mk2-equipment", count = 4, quality = "rare"},
        {name = "personal-laser-defense-equipment", count = 3, quality = "normal"},
        {name = "super-red-bot", count = 160, quality = "normal"}
    }

    for _, item in ipairs(items) do
        inventory.insert({name = item.name, count = item.count, quality = item.quality})
    end
    
    player.print("RDS Supply Drop received: Check your inventory for armor and modules.")
end

-- This function handles the "Auto-Equip" on Spawn
local function give_rds_kit(player)
    if not player or not player.valid or not player.character then return false end
    
    local inventory = player.get_main_inventory()
    local armor_inv = player.get_inventory(defines.inventory.character_armor)
    if not inventory or not armor_inv then return false end

    if inventory.get_item_count("mech-armor") > 0 or armor_inv.get_item_count("mech-armor") > 0 then 
        return true 
    end

    armor_inv.insert({name = "mech-armor", count = 1, quality = "rare"})
    local armor_stack = armor_inv[1]

    if armor_stack and armor_stack.valid_for_read and armor_stack.grid then
        local grid = armor_stack.grid
        local equipment = {
            {name = "fusion-reactor-equipment", count = 5, quality = "epic"},
            {name = "exoskeleton-equipment", count = 5, quality = "rare"},
            {name = "personal-roboport-mk2-equipment", count = 4, quality = "rare"},
            {name = "energy-shield-mk2-equipment", count = 3, quality = "rare"},
            {name = "battery-mk2-equipment", count = 4, quality = "rare"},
            {name = "personal-laser-defense-equipment", count = 3, quality = "normal"}
        }

        for _, item in ipairs(equipment) do
            for i = 1, item.count do
                grid.put({name = item.name, quality = item.quality})
            end
        end
        
        inventory.insert({name = "super-red-bot", count = 160})
        player.print("RDS Kit auto-deployed and equipped.")
        return true
    end
    return false
end

-- Events
script.on_event({defines.events.on_player_created, defines.events.on_player_respawn}, function(event)
    storage.rds_queue = storage.rds_queue or {}
    storage.rds_queue[event.player_index] = game.tick + 300
end)

script.on_event(defines.events.on_tick, function(event)
    -- Handle Auto-Spawn Queue
    if storage.rds_queue and event.tick % 30 == 0 then
        for player_index, spawn_tick in pairs(storage.rds_queue) do
            if event.tick >= spawn_tick then
                local player = game.players[player_index]
                if player and player.valid then
                    if give_rds_kit(player) then
                        storage.rds_queue[player_index] = nil
                    end
                end
            end
        end
    end

    -- Handle Treenocide Logic
    if storage.rds_settings.treenocide and event.tick % 15 == 0 then
        for _, player in pairs(game.connected_players) do
            if player.character and player.get_inventory(defines.inventory.character_armor).get_item_count("mech-armor") > 0 then
                -- Find up to 3 trees at once for more "firepower"
                local trees = player.surface.find_entities_filtered{
                    type = "tree",
                    position = player.position,
                    radius = storage.rds_settings.harbinger_range,
                    limit = 3
                }
                
                for _, tree in ipairs(trees) do
                    -- 1. Create visual beam/bolt
                    player.surface.create_entity{
                        name = "harbinger-bolt", 
                        position = player.position,
                        target = tree,
                        speed = 1.0
                    }
                    -- 2. Force the tree to die (Simulating the hit)
                    -- We use damage() so it benefits from the "explosive" effect if defined
                    tree.damage(100, player.force, "explosion", player.character)
                end
            end
        end
    end
end)

--- COMMANDS ---

commands.add_command("help_rds", "Displays info about the RDS Mod", function(command)
    local player = game.players[command.player_index]
    if player then
        local version = script.active_mods["Rapid-Deployment-Start"] or "unknown"
        player.print("--- Rapid Deployment Start (RDS) v" .. version .. " ---")
        player.print("Commands:")
        player.print("/rds_deploy - Manual supply drop")
        player.print("/bots_for_the_bots_throne - Give 25 bots")
        player.print("/rds_set_harbinger_range [num] - Current: " .. storage.rds_settings.harbinger_range)
    end
end)

commands.add_command("rds_deploy", "Receive all kit items in inventory", function(command)
    local player = game.players[command.player_index]
    if player and player.valid then rds_supply_drop(player) end
end)

commands.add_command("bots_for_the_bots_throne", "Grants 25 super red bots", function(command)
    local player = game.players[command.player_index]
    if player and player.valid then
        player.get_main_inventory().insert({name = "super-red-bot", count = 25})
        player.print("25 more bots for the throne!")
    end
end)

commands.add_command("rds_set_harbinger_range", "Set Harbinger range", function(command)
    local val = tonumber(command.parameter)
    if val then
        storage.rds_settings.harbinger_range = val
        game.print("Harbinger range updated to: " .. val)
    end
end)

