-- HARBINGER PROJECTILE (Massive Explosion)
local bolt = {
    type = "projectile",
    name = "harbinger-bolt",
    flags = {"not-on-map"},
    acceleration = 0.01,
    action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {{
                type = "nested-result",
                action = {
                    type = "area",
                    radius = 9,
                    action_delivery = {
                        type = "instant",
                        target_effects = {
                            {type = "damage", damage = {amount = 3000, type = "explosion"}},
                            {type = "create-entity", entity_name = "big-artillery-explosion"}
                        }
                    }
                }
            }}
        }
    },
    light = {intensity = 0.4, size = 5, color = {r=1, g=0.2, b=0}},
    animation = {
        filename = "__base__/graphics/entity/explosion/explosion-3.png",
        priority = "high", width = 64, height = 64, frame_count = 1, tint = {r=1, g=0.2, b=0}
    },
    speed = 0.9
}
data:extend({bolt})

-- HARBINGER LASER OVERRIDE
local laser = data.raw["active-defense-equipment"]["personal-laser-defense-equipment"]
if laser then
    -- Namen und Beschreibung erzwingen (WICHTIG!)
    laser.localised_name = "The Harbinger (RDS Special)"
    laser.localised_description = "RDS Modifiziert: Schießt hochexplosive Projektile mit extremer Reichweite."
    
    -- Optik
    laser.sprite.tint = {r=1, g=0, b=0, a=1}
    
    -- Stats
    if laser.attack_parameters then
        laser.attack_parameters.range = 100
        laser.attack_parameters.cooldown = 20 -- Etwas langsamer, weil es so stark ist
        
        -- Das Projektil-System erzwingen
        laser.attack_parameters.ammo_type = {
            category = "laser",
            energy_consumption = "10kJ",
            action = {
                type = "direct",
                action_delivery = {
                    type = "projectile",
                    projectile = "harbinger-bolt",
                    starting_speed = 0.9
                }
            }
        }
    end
end

-- ROBOPORT CHARGE BOOST (Damit die roten Bots nicht warten müssen)
if data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"] then
    data.raw["roboport-equipment"]["personal-roboport-mk2-equipment"].charging_energy = "1000kW"
end