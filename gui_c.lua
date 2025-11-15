local function openPVPFunction()
	if isElement(pvpGUI) then
		return closePVPFunction();
	else
		pvpGUI = guiCreateWindow(0.37, 0.35, 0.25, 0.30, "SAES:RPG PvP v0.2", true)
		guiWindowSetMovable(pvpGUI, false)
		guiWindowSetSizable(pvpGUI, false)

		closeButton = guiCreateButton(0.74, 0.88, 0.22, 0.08, "Close", true, pvpGUI)
		requestButton = guiCreateButton(0.40, 0.88, 0.22, 0.08, "Request", true, pvpGUI)
		edit = guiCreateEdit(0.13, 0.09, 0.23, 0.08, "", true, pvpGUI)
		label = guiCreateLabel(.04, 0.11, 0.10, 0.05, "Player:", true, pvpGUI)
		playerList = guiCreateGridList(0.02, 0.19, 0.34, 0.78, true, pvpGUI)
		guiGridListAddColumn(playerList, "Player", 0.9)
		for i, v in pairs(getElementsByType("player")) do
			if v ~= localPlayer then
				local row = guiGridListAddRow(playerList)
				guiGridListSetItemText(playerList, row, 1, getPlayerName(v), false, false)
				guiGridListSetItemData(playerList, row, 1, v)
			end
		end
		label = guiCreateLabel(0.40, 0.10, 0.17, 0.06, "Gamemodes", true, pvpGUI)
        guiSetFont(label, "default-bold-small")
        guiLabelSetColor(label, 255, 0, 0)
		modeList = guiCreateGridList(0.38, 0.19, 0.60, 0.48, true, pvpGUI)
		guiGridListAddColumn(modeList, "Gamemode", 0.9)
		infolabel = guiCreateLabel(0.40, 0.70, 0.56, 0.14, "Gamemode info: N/A", true, pvpGUI)
		guiLabelSetHorizontalAlign(infolabel, "left", true)
		if pvpList then
			for i, v in pairs(pvpList) do
				local row = guiGridListAddRow(modeList)
				guiGridListSetItemText(modeList, row, 1, i, false, false)
				guiGridListSetItemData(modeList, row, 1, v)
			end
		end
		showCursor(true)
		addEventHandler("onClientGUIClick", guiRoot, onClickPVPGUI)
		addEventHandler("onClientGUIChanged", edit, onPVPGUIChange)
	end
end
addEvent("saespvp.openGUI", true)
addEventHandler("saespvp.openGUI", localPlayer, openPVPFunction)

function onClickPVPGUI()
	if not isElement(pvpGUI) then
		return
	end
	if source == requestButton then
		if guiGridListGetSelectedCount(playerList) == 1 then
			if guiGridListGetSelectedCount(modeList) == 1 then
				local thePlayer = guiGridListGetItemData(playerList, guiGridListGetSelectedItem(playerList), 1)
				local theMode = guiGridListGetItemText(modeList, guiGridListGetSelectedItem(modeList), 1)
				if thePlayer ~= localPlayer then
					triggerServerEvent("saespvp.requestMode", resourceRoot, thePlayer, theMode)
					closePVPFunction()
				end
			else
				outputChatBox("*PVP* You have to click a gamemode to submit a PVP request", 255, 0, 0)
			end
		else
			outputChatBox("*PVP* You have to select a player to submit a PVP request", 255, 0, 0)
		end
	elseif source == modeList then
		if guiGridListGetSelectedCount(modeList) == 1 then
			local data = guiGridListGetItemData(modeList, guiGridListGetSelectedItem(modeList), 1)
			guiSetText(infolabel, "Gamemode info: ".. data.description)
		end
	elseif source == closeButton then
		closePVPFunction()
	end
end

function onPVPGUIChange()
	if not isElement(pvpGUI) then
		return
	end
	guiGridListClear(playerList)
	local text = guiGetText(source)
	for k, v in pairs(getElementsByType("player")) do
		if v ~= localPlayer then
			local row = guiGridListAddRow(playerList)
			if string.find(string.upper(getPlayerName(v)), string.upper(text), 1, true) then
				guiGridListSetItemText(playerList, row, 1, getPlayerName(v), false, false)
				guiGridListSetItemData(playerList, row, 1, v)
			end
		end
	end
end

function closePVPFunction()
	if not isElement(pvpGUI) then
		return
	end
	showCursor(false)
	removeEventHandler("onClientGUIClick", guiRoot, onClickPVPGUI)
	removeEventHandler("onClientGUIChanged", edit, onPVPGUIChange)
	destroyElement(pvpGUI)
end
