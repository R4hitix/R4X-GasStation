--[[
    R4x Gas Station v2.0.0
    Modern fuel system for FiveM with ESX
    
    Features:
    - Gasoline, Diesel, Electric support
    - Modern React NUI interface
    - ox_lib integration
    - Jerry can refueling
]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'R4x Gas Station'
description 'Modern fuel system with electric vehicle support'
author 'R4x'
version '2.0.0'

-- ============================================================
-- DEPENDENCIES
-- ============================================================

dependencies {
    'ox_lib'
}

-- ============================================================
-- SHARED SCRIPTS
-- ============================================================

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

-- ============================================================
-- CLIENT SCRIPTS
-- ============================================================

client_scripts {
    'data/stations.lua',
    'client/utils.lua',
    'client/client.lua'
}

-- ============================================================
-- SERVER SCRIPTS
-- ============================================================

server_script 'server/*.lua'

-- ============================================================
-- NUI CONFIGURATION
-- ============================================================

ui_page 'web/build/index.html'

files {
    'locales/*.json',
    'web/build/index.html',
    'web/build/**/*'
}