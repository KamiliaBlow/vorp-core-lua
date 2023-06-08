local setDead = false
local TimeToRespawn = 1
local Dead = false
local cam = nil
local angleY = 0.0
local angleZ = 0.0
local prompts = GetRandomIntInRange(0, 0xffffff)
local prompt
local PressKey = false
local carried = false
local Done = false

local T = Translation[Lang].MessageOfSystem

-- RegisterNetEvent('vorp:SelectedCharacter', function() --/ Change accordingly to your FW or do something else to initialize those funcs.
    -- DeathCam2()
    -- DeathCam1()
-- end)

--================================= FUNCTIONS ==========================================--

---GET LABLE FOR PROMPT
---@return string
local CheckLable = function()
    if not carried then
        if not Done then
            local label = CreateVarString(10, 'LITERAL_STRING',
                T.RespawnIn ..
                TimeToRespawn .. T.SecondsMove .. T.message)
            return label
        else
            local label = CreateVarString(10, 'LITERAL_STRING', T.message2)
            return label
        end
    else
        local label = CreateVarString(10, 'LITERAL_STRING', T.YouAreCarried)
        return label
    end
end

---comment
---@return table
local ProcessNewPosition = function()
    local mouseX = 0.0
    local mouseY = 0.0
    
    -- keyboard
    if (IsInputDisabled(0)) then
        -- rotation
        mouseX = GetDisabledControlNormal(1, 0x6BC904FC) * 5.0
        mouseY = GetDisabledControlNormal(1, 0x84574AE8) * 5.0
        
    -- controller
    else
        -- rotation
        mouseX = GetDisabledControlNormal(1, 0x6BC904FC) * 0.5
        mouseY = GetDisabledControlNormal(1, 0x84574AE8) * 0.5
    end

    angleZ = angleZ - mouseX -- around Z axis (left / right)
    angleY = angleY + mouseY -- up / down
    -- limit up / down angle to 90°
    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end
    
    local pCoords = GetEntityCoords(PlayerPedId())
    
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (0.5 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (0.5 + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (0.5 + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    local maxRadius = 3.5
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.0, hitCoords) < 0.5 + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.0, hitCoords)
    end
    
    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }
    
    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }
    
    
    -- Debug x,y,z axis
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.03, 0.03, 5.0, 0, 0, 255, 255, false, false, 2, false, 0, false)
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0, 0.03, 0.03, 5.0, 255, 0, 0, 255, false, false, 2, false, 0, false)
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 0.03, 0.03, 5.0, 0, 255, 0, 255, false, false, 2, false, 0, false)
    
    return pos
end

local EndDeathCam = function()
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    cam = nil
end

local keepdown
local ResurrectPlayer = function()
    local player = PlayerPedId()
	
	ResurrectPed(player)
	local innerHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0)
    SetEntityHealth(player, Config.HealthOnResurrection + innerHealth)
	
	SetPedToRagdoll(player,1000, 1000, 0, 0, 0, 0)
	ResetPedRagdollTimer(player)
	DisablePedPainAudio(player, true)
	
    Citizen.InvokeNative(0xCE7A90B160F75046, false)
    if Config.HideUi then -- SHOW VORP core ui
        TriggerEvent("vorp:showUi", false)
    else
        TriggerEvent("vorp:showUi", true)
    end

    EndDeathCam()
    TriggerServerEvent("vorp:ImDead", false)
    setDead = false
	Wait(100)
	NetworkSetInSpectatorMode(false, player)
    DisplayHud(true)
    DisplayRadar(true)
    setPVP()
    TriggerEvent("vorpcharacter:reloadafterdeath")
end

ResspawnPlayer = function()
    local player = PlayerPedId()

    ResurrectPed(player)
    local innerHealth = Citizen.InvokeNative(0x36731AC041289BB1, player, 0)
    SetEntityHealth(player, Config.HealthOnRespawn + innerHealth)
	SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
	ResetPedRagdollTimer(player)
	DisablePedPainAudio(player, true)
	
	EndDeathCam()
	
    Citizen.Wait(100)
    TriggerServerEvent("vorpcharacter:getPlayerSkin")
    TriggerServerEvent("vorp:ImDead", false)
    setDead = false
    NetworkSetInSpectatorMode(false, player)
    DisplayHud(true)
    DisplayRadar(true)
    setPVP()
end

local StartDeathCam = function()
    ClearFocus()
    local playerPed = PlayerPedId()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

local ProcessCamControls = function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(PlayerPedId())
    -- disable 1st person as the 1st person camera can cause some glitches
    Citizen.InvokeNative(0x05AB44D906738426)
    
    -- calculate new position
    local newPos = ProcessNewPosition()

    -- set coords of cam
    Citizen.InvokeNative(0xF9EE7D419EE49DE6,cam, newPos.x, newPos.y, newPos.z)
    
    -- set rotation
    Citizen.InvokeNative(0x948B39341C3A40C2,cam, playerCoords.x, playerCoords.y, playerCoords.z)
end


function DeathCam1()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            
            if (cam and Dead) then
                ProcessCamControls()
            end
        end
    end)
end

function DeathCam2()
    Citizen.CreateThread(function()
        while true do
            local ped = PlayerPedId()
            Citizen.Wait(500)
            if not Dead and IsPedDeadOrDying(ped) then
                Dead = true
                StartDeathCam()
            elseif Dead and not IsPedDeadOrDying(ped) then
                Dead = false
                EndDeathCam()
            end
        end
    end)
end

-- CREATE PROMPT
CreateThread(function()
    Wait(1000)
    local str = T.prompt
    local keyPress = Config.RespawnKey
    prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, 1)
    PromptSetVisible(prompt, 1)
    PromptSetHoldMode(prompt, Config.RespawnKeyTime)
    PromptSetGroup(prompt, prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, prompt, true)
    PromptRegisterEnd(prompt)
end)

--============================ EVENTS ================================--

-- revive player from server side use this event to revive and not teleport
RegisterNetEvent('vorp:resurrectPlayer', function(just)
    local dont = false
    local justrevive = just or true
    ResurrectPlayer(dont, nil, justrevive)
end)

-- respawn player from server side
RegisterNetEvent('vorp_core:respawnPlayer', function()
    ResspawnPlayer()
end)

---RESPAWN TIME
local RespawnTimer = function()
    CreateThread(function() -- asyncronous
        while true do
            Wait(1000)      -- every second
            TimeToRespawn = TimeToRespawn - 1
            if TimeToRespawn < 0 and setDead then
                TimeToRespawn = 0
                break -- break the loop
            end
        end
    end)
end

-- use this events to request more time to a player to wait for respawn  for example if they call a doctor they need to wait if doctor answers back
RegisterNetEvent("vorp_core:Client:AddTimeToRespawn")               -- from server
AddEventHandler("vorp_core:Client:AddTimeToRespawn", function(time) -- from client
    if TimeToRespawn >= 1 then                                      -- if still has time then add more
        TimeToRespawn = TimeToRespawn + time
    else                                                            -- if not then create new timer
        RespawnTimer()
    end
end)
--=========================== DEATH HANDLER =================================--


--DEATH HANDLER
CreateThread(function()
    while Config.UseDeathHandler do
        Wait(0)
        local sleep = true
        local player = PlayerPedId() -- call it once

        if IsEntityDead(player) then -- if player is dead
            sleep = false
            if not setDead then      -- set only once
                NetworkSetInSpectatorMode(false, player)
                exports.spawnmanager.setAutoSpawn(false)
                TriggerServerEvent("vorp:ImDead", true)
                DisplayRadar(false)
                TimeToRespawn = Config.RespawnTime
                CreateThread(function() -- asyncronous timer
                    RespawnTimer()
					DeathCam1()
                    DeathCam2()
                end)
                PressKey = false
                setDead = true
                PromptSetEnabled(prompt, 1)
            end

            if not PressKey and setDead then
                if not IsEntityAttachedToAnyPed(player) then -- is not  player being carried
                    PromptSetActiveGroupThisFrame(prompts, CheckLable())

                    if PromptHasHoldModeCompleted(prompt) then
                        ResspawnPlayer()
                        PressKey = true
                        carried  = false
                        Done     = false
                        sleep    = true
                    end

                    if TimeToRespawn >= 1 and setDead then -- message will only show if timer has not been met
						ProcessCamControls()
                        Done = false
                        PromptSetEnabled(prompt, 0)
                    else
						ProcessCamControls()
                        Done = true
                        PromptSetEnabled(prompt, 1)
                    end
                    carried = false
                else -- if is being carried
                    if setDead then
                        PromptSetActiveGroupThisFrame(prompts, CheckLable())
                        PromptSetEnabled(prompt, 0)
                        ProcessCamControls()
                        carried = true
                    end
                end
            end
        else
            sleep = true
        end
        if sleep then -- controller
            Wait(1000)
        end
    end
end)
