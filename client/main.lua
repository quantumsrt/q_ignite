local lib = exports.ox_lib

local engineState = {}
local displayingUI = false
local isStationary = false
local stationaryTimer = 0
local justIgnited = false
local ignitionTimer = 0
local engineJustKilled = false
local killTimer = 0
local isStartingEngine = false
local justEnteredVehicle = false
local vehicleEntryTimer = 0

-- Function to check if vehicle should use this system
local function shouldUseSystem(vehicle)
    if not vehicle then return false end
    
    -- Ensure Config.DisabledVehicles exists and is a table
    if not Config.DisabledVehicles or type(Config.DisabledVehicles) ~= "table" then
        Config.DisabledVehicles = {}
        return true
    end
    
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model):lower()
    
    for _, disabledModel in ipairs(Config.DisabledVehicles) do
        if modelName == disabledModel:lower() then
            return false
        end
    end
    return true
end

-- Function to check if a vehicle is completely stationary
local function isVehicleStationary(vehicle)
    local velocity = GetEntityVelocity(vehicle)
    return #vector3(velocity.x, velocity.y, velocity.z) < 0.1
end

-- Function to handle TextUI display
local function handleTextUI(state, force)
    if not Config.EnableTextUI then return end
    
    if not displayingUI or force then
        local message = state and Config.TextUI.messages.kill or Config.TextUI.messages.ignite
        message = message:format(Config.GetKeyName())
        
        lib:showTextUI(message, {
            position = Config.TextUI.position,
            icon = Config.TextUI.icon,
            style = Config.TextUI.style
        })
        displayingUI = true
    end
end

-- Function to hide TextUI
local function hideTextUI()
    if displayingUI then
        lib:hideTextUI()
        displayingUI = false
    end
end

-- Function to play vehicle start animation and sound
local function playVehicleStartAnimation(vehicle)
    -- Simulate W key press
    SetControlNormal(0, 71, 1.0)
    Wait(Config.WKeyPressTime)
    SetControlNormal(0, 71, 0.0)
    
    -- Play engine sound if enabled
    if Config.Sounds.enabled then
        PlaySoundFromEntity(-1, 
            Config.Sounds.engineStart.soundName,
            vehicle, 
            Config.Sounds.engineStart.soundSet,
            true, 0)
    end
    
    Wait(Config.EngineStartDelay)
end

-- Function to toggle engine state
local function toggleEngine(vehicle)
    if not shouldUseSystem(vehicle) then return end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    local currentState = engineState[plate] or false
    
    if not currentState and not isStartingEngine then
        -- Starting engine
        isStartingEngine = true
        hideTextUI()
        
        -- Play animation and sound
        playVehicleStartAnimation(vehicle)
        
        -- Start engine after animation
        engineState[plate] = true
        SetVehicleEngineOn(vehicle, true, true, false)
        
        -- Set timers and flags
        justIgnited = true
        ignitionTimer = GetGameTimer()
        isStartingEngine = false
    elseif currentState then
        -- Turning engine off
        engineState[plate] = false
        SetVehicleEngineOn(vehicle, false, true, true)
        justIgnited = false
        engineJustKilled = true
        killTimer = GetGameTimer()
        hideTextUI()
    end
end

-- Main thread for handling engine control
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle and DoesEntityExist(vehicle) and shouldUseSystem(vehicle) then
                sleep = 0
                local plate = GetVehicleNumberPlateText(vehicle)
                
                -- Initialize engine state if not exists
                if engineState[plate] == nil then
                    if Config.RememberState then
                        -- Keep the current engine state
                        engineState[plate] = GetIsVehicleEngineRunning(vehicle)
                        if engineState[plate] then
                            justEnteredVehicle = true
                            vehicleEntryTimer = GetGameTimer()
                            hideTextUI()
                        else
                            handleTextUI(false, true)
                        end
                    else
                        -- Default to engine off
                        engineState[plate] = false
                        SetVehicleEngineOn(vehicle, false, true, true)
                        handleTextUI(false, true)
                    end
                end
                
                -- Maintain engine state
                SetVehicleEngineOn(vehicle, engineState[plate], true, true)
                
                -- Handle engine state
                if engineState[plate] then
                    if justIgnited then
                        -- Check if delay has passed since ignition
                        if GetGameTimer() - ignitionTimer >= Config.IgnitionDelay then
                            justIgnited = false
                            if isVehicleStationary(vehicle) then
                                handleTextUI(true)
                            end
                        end
                    elseif justEnteredVehicle then
                        if GetGameTimer() - vehicleEntryTimer >= Config.StationaryDelay then
                            justEnteredVehicle = false
                            if isVehicleStationary(vehicle) then
                                handleTextUI(true)
                                isStationary = true
                                stationaryTimer = GetGameTimer()
                            end
                        end
                    elseif isVehicleStationary(vehicle) then
                        if not isStationary then
                            isStationary = true
                            stationaryTimer = GetGameTimer()
                            hideTextUI()
                        elseif GetGameTimer() - stationaryTimer >= Config.StationaryDelay then
                            handleTextUI(true)
                        end
                    else
                        isStationary = false
                        stationaryTimer = 0
                        hideTextUI()
                    end
                else
                    -- Show "Ignite Engine" TextUI after delay
                    if engineJustKilled then
                        if GetGameTimer() - killTimer >= Config.KillEngineDelay then
                            engineJustKilled = false
                            handleTextUI(false)
                        end
                    elseif not engineJustKilled and not isStartingEngine then
                        handleTextUI(false)
                    end
                end
                
                -- Handle engine control key press
                if IsControlJustPressed(0, Config.EngineControlKey) and not isStartingEngine then
                    toggleEngine(vehicle)
                end
            end
        else
            -- Only hide UI when leaving vehicle
            hideTextUI()
            isStationary = false
            justIgnited = false
            engineJustKilled = false
            isStartingEngine = false
            justEnteredVehicle = false
            stationaryTimer = 0
        end
        
        Wait(sleep)
    end
end)

-- Event handler for vehicle entry
RegisterNetEvent('gameEventTriggered')
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkPlayerEnteredVehicle' then
        local vehicle = args[2]
        if DoesEntityExist(vehicle) and shouldUseSystem(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            
            -- Check if we should initialize the engine state
            if engineState[plate] == nil then
                if Config.RememberState then
                    -- Keep the current engine state
                    engineState[plate] = GetIsVehicleEngineRunning(vehicle)
                    if engineState[plate] then
                        justEnteredVehicle = true
                        vehicleEntryTimer = GetGameTimer()
                        hideTextUI()
                    else
                        handleTextUI(false, true)
                    end
                else
                    -- Default to engine off
                    engineState[plate] = false
                    SetVehicleEngineOn(vehicle, false, true, true)
                    handleTextUI(false, true)
                end
            else
                if engineState[plate] then
                    justEnteredVehicle = true
                    vehicleEntryTimer = GetGameTimer()
                    hideTextUI()
                else
                    handleTextUI(false, true)
                end
            end
            
            -- Apply the engine state
            SetVehicleEngineOn(vehicle, engineState[plate], true, true)
        end
    end
end)

-- Event handler for vehicle exit
AddEventHandler('gameEventTriggered', function(name)
    if name == 'CEventNetworkPlayerLeftVehicle' then
        -- Only hide the UI, don't change engine state
        hideTextUI()
    end
end)

-- Initialization when resource starts
CreateThread(function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if DoesEntityExist(vehicle) and shouldUseSystem(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle)
            if Config.RememberState then
                engineState[plate] = GetIsVehicleEngineRunning(vehicle)
                if engineState[plate] then
                    justEnteredVehicle = true
                    vehicleEntryTimer = GetGameTimer()
                    hideTextUI()
                else
                    handleTextUI(false, true)
                end
            else
                engineState[plate] = false
                SetVehicleEngineOn(vehicle, false, true, true)
                handleTextUI(false, true)
            end
        end
    end
end)
