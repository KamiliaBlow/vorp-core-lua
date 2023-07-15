local T = Translation[Lang].MessageOfSystem

--=================================== FUNCTIONS ======================================--

---comment
---@param hash string
---@return boolean
LoadModel = function(hash)
    if IsModelValid(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end
        return true
    end
    return false
end

---comment
---@param hash any
---@return boolean
LoadTexture = function(hash)
    if not HasStreamedTextureDictLoaded(hash) then
        RequestStreamedTextureDict(hash, true)
        while not HasStreamedTextureDictLoaded(hash) do
            Wait(1)
        end
        return true
    end
    return false
end

---comment
---@param text string
---@return unknown
bigInt = function(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end

--[[DrawText = function(text, font, x, y, fontscale, fontsize, r, g, b, alpha, textcentred, shadow)
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(fontscale, fontsize)
    SetTextColor(r, g, b, alpha)
    SetTextCentre(textcentred)
    if shadow then SetTextDropshadow(1, 0, 0, 0, 255) end
    SetTextFontForCurrentCommand(font)
    DisplayText(str, x, y)
end]]

--========================================== THREADS =========================================--

-- remove event notifications

local Events = {
    `EVENT_CHALLENGE_GOAL_COMPLETE`,
    `EVENT_CHALLENGE_REWARD`,
    `EVENT_DAILY_CHALLENGE_STREAK_COMPLETED`
}


RegisterCommand("reload", function()
    if IsEntityDead(PlayerPedId()) then
        ExecuteCommand("rc")
    end

end)
CreateThread(function()
    while true do
        Wait(0)
        local event = GetNumberOfEvents(0)
        if event > 0 then
            for i = 0, event - 1 do
                local eventAtIndex = GetEventAtIndex(0, i)
                for _, value in pairs(Events) do
                    if eventAtIndex == value then
                        Citizen.InvokeNative(0x6035E8FBCA32AC5E) -- remove events
                    end
                end
            end
        end
        if Config.disableAutoAIM then
            Citizen.InvokeNative(0xD66A941F401E7302, 3)
            Citizen.InvokeNative(0x19B4F71703902238, 3)
        end
    end
end)

-- show players id when focus on other players
CreateThread(function()
    while true do
        Citizen.Wait(400)
		local closestPlayer, closestDistance = GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance < 15.0 then
			print("ped: "..tostring(GetPlayerServerId(closestPlayer)))
			TriggerServerEvent("vorp_rbm:first_last", GetPlayerServerId(closestPlayer), GetPlayerServerId(closestPlayer))			
		end
    end
end)

RegisterNetEvent("first_last_tar") --items
AddEventHandler("first_last_tar", function(name, id)
	local closestPlayer, closestDistance = GetClosestPlayer()
	local ped = GetPlayerPed(closestPlayer)
	if closestPlayer ~= -1 and closestDistance < 5.0 then
		--print("id: "..tostring(closestPlayer))
		--print("name: "..tostring(name))
		--print("ped: "..tostring(ped))
		SetPedPromptName(ped, name.." : ".. tostring(GetPlayerServerId(closestPlayer)))
	elseif closestPlayer ~= -1 and closestDistance < 15.0 and closestDistance > 5.5 then
		if IsPedMale(ped) then
			SetPedPromptName(ped, "Незнакомец : ".. tostring(GetPlayerServerId(closestPlayer)))
			--print("Незнакомец: "..tostring(ped))
		else
			SetPedPromptName(ped, "Незнакомка : ".. tostring(GetPlayerServerId(closestPlayer)))
			--print("Незнакомка: "..tostring(ped))
		end
	end
end)

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false
    
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end
    
    for i=1, #players, 1 do
        local tgt = GetPlayerPed(players[i])
        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then

            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                if PlayerPedId() ~= GetPlayerPed(players[i]) then
                    closestPlayer = players[i]
                    closestDistance = distance
                end
            end
        end
    end
    return closestPlayer, closestDistance
end

-- hide or show players cores
CreateThread(function()
    Citizen.Wait(5000)
    if Config.HideOnlyDEADEYE then
        Citizen.InvokeNative(0xC116E6DF68DCE667, 2, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 3, 2)
    end
    if Config.HidePlayersCore then
        Citizen.InvokeNative(0xC116E6DF68DCE667, 0, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 1, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 2, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 3, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 4, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 5, 2)

    end
    if Config.HideHorseCores then
        Citizen.InvokeNative(0xC116E6DF68DCE667, 6, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 7, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 8, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 9, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 10, 2)
        Citizen.InvokeNative(0xC116E6DF68DCE667, 11, 2)
    end
end)



--================================================================================================--
