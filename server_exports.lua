function isPlayerPVP(player)
	if pvpTable[player] then
		return true;
	end
end

function outputMessage(message, target, r, g, b)
    if isElement(target) and getElementType(target) == "player" then
        outputChatBox('*PVP* '..message, target, r, g, b)
    end
end
