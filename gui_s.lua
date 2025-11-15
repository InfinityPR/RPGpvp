local pvpRequest = {}

local function openPVP(player)
	if getPlayerIdleTime(player) < 1000 then
		outputMessage("You cannot be in motion to be able to open this panel!", player, 255, 0, 0, false)
		return
	end
	if getElementDimension(player) ~= 0 then
		outputMessage("You must be on the main dimension to open this panel!", player, 255, 0, 0, false)
		return
	end
	triggerClientEvent(player, "saespvp.openGUI", player)
end
addCommandHandler("pvp", openPVP)

local function cancelPVPRequest(player, againstWho)
	if not isElement(player) then
		return
	end
	if not isElement(againstWho) then
		return
	end
	pvpRequest[player] = nil
	if pvpRequest[againstWho] then
		pvpRequest[againstWho] = nil
		outputMessage("The PVP request has been cancelled", againstWho, 255, 0, 0)
	end
end

local function clientRequestedPVP(againstWho, theMode)
	if not isElement(client) then
		return
	end
	if not isElement(againstWho) then
		return
	end
	if isPlayerPVP(client) or isPlayerPVP(againstWho) then
		outputMessage("You/player are already part of a PVP match", client, 255, 0, 0)
		return
	end
	if pvpRequest[client] or pvpRequest[againstWho] then
		outputMessage("You/player already have an active PVP request", client, 255, 0, 0)
		return
	end
	pvpRequest[client] = true
	pvpRequest[againstWho] = {client, theMode}
	outputMessage("A PVP request has been sent to ".. getPlayerName(againstWho) .."", client, 0, 255, 0)
	outputMessage("A PVP request has been sent from ".. getPlayerName(client) .."", againstWho, 0, 255, 0)
	outputMessage("Gamemode: '".. theMode .."'. Type /pvpaccept to accept.", againstWho, 0, 255, 0)
	setTimer(cancelPVPRequest, 20000, 1, client, againstWho)
	playSoundFrontEnd(againstWho, 40)
end
addEvent("saespvp.requestMode", true)
addEventHandler("saespvp.requestMode", resourceRoot, clientRequestedPVP)

local function acceptPVPRequest(player)
	if not pvpRequest[player] then
		return
	end
	local againstWho = pvpRequest[player][1]
	local theMode = pvpRequest[player][2]
	if not isElement(againstWho) then
		return
	end
	if getPedOccupiedVehicle(player) or getPedOccupiedVehicle(againstWho) then
		outputMessage("*Info* You/player are inside of a vehicle and cannot proceed request", player, 255, 0, 0)
		return
	end
	outputMessage("The PVP request from ".. getPlayerName(againstWho) .." was accepted! Joining arena in 10 seconds", player, 255, 255, 255)
	outputMessage("".. getPlayerName(player) .." has accepted your PVP request! Joining arena in 10 seconds", againstWho, 255, 255, 255)
	setElementFrozen(player, true)
	setElementFrozen(againstWho, true)
	setTimer(createPVPArena, 10000, 1, againstWho, player, theMode)
	pvpRequest[player] = nil
	pvpRequest[againstWho] = nil
end
addCommandHandler("pvpaccept", acceptPVPRequest)
