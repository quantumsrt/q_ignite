fx_version 'cerulean'
game 'gta5'

author 'quantum'
description 'Ignition System - quantum'
version '1.0.0'

-- Shared configuration and utility scripts
shared_scripts {
    'shared/config.lua'
}

-- Include all client-side scripts
client_scripts {
    'client/main.lua'
}

-- Required dependencies
dependencies {
    'ox_lib'
}