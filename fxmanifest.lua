-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Coffeelot & Wuggie'
description 'CW Racing App'
version '3.5.10'

ui_page {
    "html/dist/index.html"
}

shared_scripts {
    'locales/en.lua',
    'config.lua',
    '@ox_lib/init.lua',
    '@qbx_core/modules/playerdata.lua'
}

client_scripts {
    'bridge/client/*.lua',
    'client/functions.lua',
    'client/main.lua',
}

server_scripts {
    '@ox_core/imports/server.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'bridge/server/*.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/crews.lua',
    'server/elo.lua'
}

files {
    "html/dist/index.html",
    "html/dist/assets/*.*",
}

dependencies {
    'cw-performance'
}

lua54 'yes'
