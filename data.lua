-- HIGH-SPEED CONSTRUCTION ROBOTS
local bot_source = data.raw["construction-robot"]["construction-robot"]
if bot_source then
    local red_bot = table.deepcopy(bot_source)
    red_bot.name = "super-red-bot"
    red_bot.speed = 1.39
    red_bot.working_speed = 1.39
    red_bot.max_energy = "50MJ" 
    red_bot.energy_per_tick = "0.001kJ"
    red_bot.energy_per_move = "0.001kJ" 
    red_bot.max_payload_size = 5
    red_bot.speed_multiplier_when_out_of_energy = 0.5 

    local function apply_red_tint(animation)
        if animation then animation.tint = {r=1, g=0, b=0, a=1} end
    end

    red_bot.icons = {{icon = "__base__/graphics/icons/construction-robot.png", icon_size = 64, tint = {r=1, g=0, b=0}}}
    apply_red_tint(red_bot.idle_animation)
    apply_red_tint(red_bot.in_motion_animation)
    if red_bot.working_animations then 
        for _, anim in pairs(red_bot.working_animations) do apply_red_tint(anim) end 
    end

    local red_bot_item = table.deepcopy(data.raw["item"]["construction-robot"])
    red_bot_item.name = "super-red-bot"
    red_bot_item.place_result = "super-red-bot"
    red_bot_item.icons = {{icon = "__base__/graphics/icons/construction-robot.png", icon_size = 64, tint = {r=1, g=0, b=0}}}
    
    data:extend({red_bot, red_bot_item})
end