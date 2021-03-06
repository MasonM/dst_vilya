local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

-- Your character's stats
TUNING.ESCTEMPLATE_HEALTH = 150
TUNING.ESCTEMPLATE_HUNGER = 150
TUNING.ESCTEMPLATE_SANITY = 200

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ESCTEMPLATE = {
	"mushroom_planter",
	"flint",
	"twigs",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.ESCTEMPLATE
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "esctemplate_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "esctemplate_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "esctemplate.tex" )
end

local slow_near_pickables = function(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 3)
	for k,v in pairs(ents) do
		if v.components.pickable then
			inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*0.75
			return
		end
	end
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	-- Set starting inventory
	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	-- choose which sounds this character will play
	inst.soundsname = "willow"

	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
	--inst.talker_path_override = "dontstarve_DLC001/characters/"

	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.ESCTEMPLATE_HEALTH)
	inst.components.hunger:SetMax(TUNING.ESCTEMPLATE_HUNGER)
	inst.components.sanity:SetMax(TUNING.ESCTEMPLATE_SANITY)

	-- Damage multiplier (optional)
	inst.components.combat.damagemultiplier = 1

	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
	inst:DoPeriodicTask(0.1, slow_near_pickables)

end

return MakePlayerCharacter("esctemplate", prefabs, assets, common_postinit, master_postinit, prefabs)
