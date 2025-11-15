local pvpRooms = 0
local maximumRooms = 65534
pvpTable = {}

function createPVPArena(player, againstWho, theMode)
	if not isElement(player) then
		return
	end
	if not isElement(againstWho) then
		return
	end
	setElementFrozen(player, false)
	setElementFrozen(againstWho, false)
	if (getElementDimension(player) ~= 0 or getElementInterior(player) ~= 0) then
		return
	end
	if (getElementDimension(againstWho) ~= 0 or getElementInterior(againstWho) ~= 0) then
		return
	end
	pvpRooms = pvpRooms + 1
	if pvpRooms >= maximumRooms then
		pvpRooms = 0
	end
	pvpTable[player] = {pvpRooms, againstWho}
	pvpTable[againstWho] = {pvpRooms, player}
	pvpTable[pvpRooms] = {["creator"] = player, ["opponent"] = againstWho, ["vehicles"] = {}, ["markers"] = {}, ["objects"] = {}}
	outputChatBox("PVP room #".. pvpRooms .." has been created!", player, 0, 255, 0)
	outputChatBox("PVP room #".. pvpRooms .." has been created!", againstWho, 0, 255, 0)
	handlePVPArena(player, againstWho, theMode)
	addEventHandler("onPlayerWasted", player, deathHandler)
	addEventHandler("onPlayerWasted", againstWho, deathHandler)
	addEventHandler("onPlayerQuit", player, quitHandler)
	addEventHandler("onPlayerQuit", againstWho, quitHandler)
end

function handlePVPArena(player, againstWho, theMode)
	local theRoom = pvpTable[player][1]
	local p1 = pvpList[theMode]["P1"]
	local p2 = pvpList[theMode]["P2"]
	setElementPosition(player, p1.x, p1.y, p1.z)
	setElementDimension(player, theRoom)
	setElementInterior(player, pvpList[theMode].interior)
	setElementPosition(againstWho, p2.x, p2.y, p2.z)
	setElementDimension(againstWho, theRoom)
	setElementInterior(againstWho, pvpList[theMode].interior)
	if pvpList[theMode].vehicle then
		local model = tonumber(pvpList[theMode].vehicle)
		local vehicle = createVehicle(model, p1.x, p1.y, p1.z, 0, 0, 0)
		setElementDimension(vehicle, theRoom)
		setElementInterior(vehicle, pvpList[theMode].interior)
		warpPedIntoVehicle(player, vehicle)
		table.insert(pvpTable[theRoom].vehicles, vehicle)
		local vehicle = createVehicle(model, p2.x, p2.y, p2.z, 0, 0, 0)
		setElementDimension(vehicle, theRoom)
		setElementInterior(vehicle, pvpList[theMode].interior)
		warpPedIntoVehicle(againstWho, vehicle)
		table.insert(pvpTable[theRoom].vehicles, vehicle)
	end
	if pvpList[theMode].race then
		local raceCoords = pvpList[theMode].race
		local marker = createMarker(raceCoords.x, raceCoords.y, raceCoords.z-1.0, "cylinder", 10, 0, 255, 0, 200)
		setElementInterior(marker, pvpList[theMode].interior)
		setElementDimension(marker, theRoom)
		addEventHandler("onPlayerMarkerHit", player, markerHandler)
		addEventHandler("onPlayerMarkerHit", againstWho, markerHandler)
		table.insert(pvpTable[theRoom].markers, marker)
	end
	if pvpList[theMode].jump then
		triggerClientEvent(player, "saespvp.togglePVPAction", player, "vehiclejump", true)
		triggerClientEvent(againstWho, "saespvp.togglePVPAction", againstWho, "vehiclejump", true)
	end
	if pvpList[theMode].shooter then
		triggerClientEvent(player, "saespvp.togglePVPAction", player, "vehicleshooter", true)
		triggerClientEvent(againstWho, "saespvp.togglePVPAction", againstWho, "vehicleshooter", true)
	end
end

function deathHandler(ammo, attacker, weapon, bodypart)
	if getElementType(source) == "player" and isPlayerPVP(source) then
		local theRoom = pvpTable[source][1]
		local opponent = pvpTable[source][2]
		outputChatBox("*Info* You have won the PVP against ".. getPlayerName(source) .."", opponent, 0, 255, 0)
		outputChatBox("*Info* You have lost the PVP against ".. getPlayerName(opponent) .."", source, 255, 255, 255)
		endPVPArena(theRoom)
		killPed(opponent)
	end
end

function markerHandler(marker, matchingDimension)
	if getElementType(source) == "player" and isPlayerPVP(source) then
		local theRoom = pvpTable[source][1]
		local opponent = pvpTable[source][2]
		outputChatBox("*Info* You have won the PVP race against ".. getPlayerName(opponent) .."", source, 0, 255, 0)
		outputChatBox("*Info* You have lost the PVP race against ".. getPlayerName(source) .."", opponent, 255, 255, 255)
		endPVPArena(theRoom)
		killPed(source)
		killPed(opponent)
	end
end

function quitHandler()
	if isPlayerPVP(source) then
		local theRoom = pvpTable[source][1]
		local opponent = pvpTable[source][2]
		outputChatBox("*Info* ".. getPlayerName(source) .." has quit!", opponent, 0, 255, 0)
		endPVPArena(theRoom)
	end
end

function endPVPArena(theRoom)
	if pvpTable[theRoom] then
		local p1 = pvpTable[theRoom]["creator"]
		local p2 = pvpTable[theRoom]["opponent"]
		for i, v in pairs(pvpTable[theRoom].vehicles) do
			if isElement(v) then
				destroyElement(v)
			end
		end
		for i, v in pairs(pvpTable[theRoom].markers) do
			if isElement(v) then
				destroyElement(v)
			end
		end
		removeEventHandler("onPlayerWasted", p1, deathHandler)
		removeEventHandler("onPlayerWasted", p2, deathHandler)
		removeEventHandler("onPlayerMarkerHit", p1, markerHandler)
		removeEventHandler("onPlayerMarkerHit", p2, markerHandler)
		removeEventHandler("onPlayerQuit", p1, quitHandler)
		removeEventHandler("onPlayerQuit", p2, quitHandler)
		triggerClientEvent(p1, "saespvp.togglePVPAction", p1, "vehiclejump")
		triggerClientEvent(p1, "saespvp.togglePVPAction", p1, "vehicleshooter")
		triggerClientEvent(p2, "saespvp.togglePVPAction", p2, "vehiclejump")
		triggerClientEvent(p2, "saespvp.togglePVPAction", p2, "vehicleshooter")
		pvpTable[p1] = nil
		pvpTable[p2] = nil
		pvpTable[theRoom] = nil
	end
end
