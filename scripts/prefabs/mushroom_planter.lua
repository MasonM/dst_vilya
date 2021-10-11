require "prefabutil"

local prefabs = { "red_mushroom" } 
local function plant(inst, pt, deployer)
	local mushroom = SpawnPrefab("red_mushroom")
	mushroom.Transform:SetPosition(pt.x, 0, pt.z)
	inst.components.finiteuses:Use(1)
	--inst:Remove()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst:AddTag("deployedplant")

	MakeInventoryFloatable(inst, "small", 0.05, 0.9)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	MakeSmallPropagator(inst)

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(9999)
	inst.components.finiteuses:SetUses(1)

	inst:AddComponent("inventoryitem")

	MakeHauntableLaunchAndIgnite(inst)

	inst:AddComponent("deployable")
	inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	inst.components.deployable.ondeploy = plant
	inst.components.deployable.keep_in_inventory_on_deploy = true

	return inst
end


local mushassets =
{
	Asset("ANIM", "anim/mushrooms.zip"),
}

return Prefab("mushroom_planter", fn, mushassets, prefabs), MakePlacer("mushroom_planter_placer", "mushrooms", "mushrooms", "idle")
