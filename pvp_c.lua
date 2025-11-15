function togglePVPClientAction(action, state)
	if action == "vehiclejump" then
		if state then
			bindKey("lshift", "down", actionPVPVehicleJump)
		else
			unbindKey("lshift", "down", actionPVPVehicleJump)
		end
	elseif action == "vehicleshooter" then
		if state then
			bindKey("mouse1", "down", actionPVPVehicleShooter)
		else
			unbindKey("mouse1", "down", actionPVPVehicleShooter)
		end
	end
end
addEvent("saespvp.togglePVPAction", true)
addEventHandler("saespvp.togglePVPAction", localPlayer, togglePVPClientAction)

function autoDestructJump()
end

function autoDestructShoot()
end

function actionPVPVehicleJump()
	if not isPedInVehicle(localPlayer) then 
		return;
	end
	if isTimer(jumpTimer) then
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if getVehicleController(vehicle) == localPlayer then
		local x, y, z = getElementVelocity(vehicle)
		setElementVelocity(vehicle, x, y, z + 0.25)
	end
	jumpTimer = setTimer(autoDestructJump, 3000, 1)
end

function actionPVPVehicleShooter()
	if not isPedInVehicle(localPlayer) then 
		return;
	end
	if isTimer(shootTimer) then
		return
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if getVehicleController(vehicle) == localPlayer then
		local x, y, z = getElementPosition(vehicle)
		createProjectile(vehicle, 19, x, y, z, 200) 
	end
	shootTimer = setTimer(autoDestructShoot, 3000, 1)
end
