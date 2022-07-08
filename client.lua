ESX                           = nil



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

end)


RegisterNetEvent('esx_lockpicking_cars:onLockpicking')
AddEventHandler('esx_lockpicking_cars:onLockpicking', function()
	ExecuteCommand('e uncuff')
		local coords = GetEntityCoords(GetPlayerPed(-1))
		local hasAlreadyLocked = false
		cars = ESX.Game.GetVehiclesInArea(coords, 30)
		local carstrie = {}
		local cars_dist = {}		
		notowned = 0
		if #cars == 0 then
			TriggerEvent('esx:showNotification', "No vehicles around.")
		else
			for j=1, #cars, 1 do
				local coordscar = GetEntityCoords(cars[j])
				local distance = Vdist(coordscar.x, coordscar.y, coordscar.z, coords.x, coords.y, coords.z)
				table.insert(cars_dist, {cars[j], distance})
			end
			for k=1, #cars_dist, 1 do
				local z = -1
				local distance, car = 999
				local veh = GetVehiclePedIsTryingToEnter(PlayerPedId(ped))
				for l=1, #cars_dist, 1 do
					if cars_dist[l][2] < distance then
						distance = cars_dist[l][2]
						car = cars_dist[l][1]
						z = l
					end
				end
				if z ~= -1 then
					table.remove(cars_dist, z)
					table.insert(carstrie, car)
				end
			end
			for i=1, #carstrie, 1 do
				local plate = ESX.Math.Trim(GetVehicleNumberPlateText(carstrie[i]))
						local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(carstrie[i]))
						vehicleLabel = GetLabelText(vehicleLabel)
						local lock = GetVehicleDoorLockStatus(carstrie[i])
						if lock == 2 then
							exports['progressBars']:startUI(20000, "Dietrich wird benutzt")
							FreezeEntityPosition(PlayerPedId(), true)
							SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"),true)
							TriggerServerEvent('esx_lockpicking_cars:onRemove', source)
							Citizen.Wait(20000)
							FreezeEntityPosition(PlayerPedId(), false)
							SetVehicleDoorsLocked(carstrie[i], 1)
							PlayVehicleDoorOpenSound(carstrie[i], 0)
							SetVehicleAlarm(veh, true)
							SetVehicleAlarmTimeLeft(veh, 4000)
							TriggerEvent('esx:showNotification', "You cracked open the car: "..vehicleLabel..)
							FreezeEntityPosition(PlayerPedId(), false)
							if not IsPedInAnyVehicle(PlayerPedId(), true) then
								TaskPlayAnim(PlayerPedId(), dict, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
							end
							SetVehicleLights(carstrie[i], 2)
							Citizen.Wait(150)
							SetVehicleLights(carstrie[i], 0)
							Citizen.Wait(150)
							SetVehicleLights(carstrie[i], 2)
							Citizen.Wait(150)
							SetVehicleLights(carstrie[i], 0)
							hasAlreadyLocked = true
						elseif lock == 0 or lock == 1  then
							TriggerEvent('esx:showNotification', "Das Auto ist bereits Offen!")
						end	
						end
				end
end)




RegisterNetEvent('esx_lockpicking_cars:RemovePoliceBlip')
AddEventHandler('esx_lockpicking_cars:RemovePoliceBlip', function()
	Citizen.Wait(90000)
	RemoveBlip(lockBlip)
    RemoveBlip(radiusLockBlipLSPD)
end)


RegisterNetEvent("esx_lockpicking_cars:setBlipPolice")
AddEventHandler("esx_lockpicking_cars:setBlipPolice", function(s, lockPickRadius)
	

	
		RemoveBlip(lockBlip)
		RemoveBlip(radiusLockBlipLSPD)

		if lockPickRadius == nil then
			lockPickRadius = blipRadius
		end

		local src = s
		local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(src)))
		lockBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
		radiusLockBlipLSPD = AddBlipForRadius(coords.x, coords.y, coords.z, lockPickRadius)
		SetBlipSprite(lockBlip, 161)
		SetBlipAsShortRange(lockBlip, true)
		SetBlipColour(lockBlip, lockCol)
		SetBlipScale(lockBlip, 1.0)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Geklautes Auto')
		EndTextCommandSetBlipName(lockBlip)
		SetBlipAlpha(radiusLockBlipLSPD, 80)
		SetBlipColour(radiusLockBlipLSPD, lockCol)

    
	TriggerServerEvent('esx_lockpicking_cars:BlipReadyPolice', source)
end)



