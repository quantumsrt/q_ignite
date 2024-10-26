Config = {}

-- Core Settings
Config.EnableTextUI = true      -- Set to false to disable all TextUI elements
Config.EngineControlKey = 166   -- Default: 166 (F5). Full list: https://docs.fivem.net/docs/game-references/controls/
Config.EngineStartDelay = 1000  -- Time in ms for engine start animation
Config.WKeyPressTime = 50       -- Duration in ms to simulate W key press during ignition

-- Engine State Timers
Config.KillEngineDelay = 2000   -- Time in ms before showing Ignite Engine UI after shutdown
Config.StationaryDelay = 6000   -- Time in ms vehicle must be stationary before showing Kill Engine UI
Config.IgnitionDelay = 7000     -- Time in ms after ignition before showing Kill Engine UI when stationary

-- TextUI Settings
Config.TextUI = {
    position = "top-center",    -- Positions: top-center, right-center, left-center, bottom-center
    style = {
        -- borderRadius = '0px',
        backgroundColor = 'rgba(0, 0, 0, 0.8)',
        color = 'white'
    },
    icon = 'key',              -- FontAwesome icon name
    messages = {
        ignite = '[%s] - Ignite Engine',  -- %s will be replaced with the key name
        kill = '[%s] - Kill Engine'
    }
}

-- Sound Settings
Config.Sounds = {
    enabled = true,
    engineStart = {
        soundName = "Starting_Engine",
        soundSet = "ALARM_KLAXON_03_SOUNDSET"
    }
}

-- Vehicle Settings
Config.DisabledVehicles = {}    -- Initialize as empty table first
Config.DisabledVehicles = {     -- Vehicles that won't use this system (use model names)
--[[ "police",
     "ambulance",
     "firetruk" ]]
}

-- Get key name for display
Config.GetKeyName = function()
    local keyMap = {
        [166] = "F5",
        [167] = "F6",
        [168] = "F7",
        [169] = "F8",
        [170] = "F9",
        [171] = "F10",
        [157] = "1",
        [158] = "2",
        [160] = "3",
        [164] = "4",
        [165] = "5"
    }
    return keyMap[Config.EngineControlKey] or tostring(Config.EngineControlKey)
end