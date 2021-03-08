local SafezoneIn = false
local SafezoneOut = false
local closestZone = 1

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(10)
	end
	for i = 1, #Config.zones, 1 do
		local szBlip = AddBlipForCoord(Config.zones[i].x, Config.zones[i].y, Config.zones[i].z)
		SetBlipAsShortRange(szBlip, true)
		SetBlipColour(szBlip, 2)
		SetBlipSprite(szBlip, 161)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.blipname)
		EndTextCommandSetBlipName(szBlip)
	end
end)

Citizen.CreateThread(function()
		Citizen.Wait(0)
	while true do
		local playerPed = PlayerPedId()
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #Config.zones, 1 do
			dist = Vdist(Config.zones[i].x, Config.zones[i].y, Config.zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local player = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(Config.zones[closestZone].x, Config.zones[closestZone].y, Config.zones[closestZone].z, x, y, z)
		local vehicle = GetVehiclePedIsIn(player, false)
		local speed = GetEntitySpeed(vehicle)

		if dist <= Config.radius then
			if not SafezoneIn then
				NetworkSetFriendlyFireOption(false)
				SetEntityCanBeDamaged(vehicle, false)
				ClearPlayerWantedLevel(PlayerId())
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				exports['mythic_notify']:PersistentAlert('start', 'safezoneAlert', 'inform', Config.safezoneMessage)
				SafezoneIn = true
				SafezoneOut = false
			end
		else
			if not SafezoneOut then
				NetworkSetFriendlyFireOption(true)
				exports['mythic_notify']:PersistentAlert('end', 'safezoneAlert')
				SetVehicleMaxSpeed(vehicle, 336*2.2369)
				SetEntityCanBeDamaged(vehicle, true)
				SafezoneOut = true
				SafezoneIn = false
			end
		end
		if SafezoneIn then
		DisableControlAction(2, 37, true)
		DisablePlayerFiring(player, true)
      	        DisableControlAction(0, 106, true)
	    if math.floor(speed*2.2369) == Config.speedlimitinSafezone then
		cruise = speed
		SetVehicleMaxSpeed(vehicle, speed)
			if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
			if IsDisabledControlJustPressed(0, 106) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
	end
end
end
end)