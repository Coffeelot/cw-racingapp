-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Coffeelot & Wuggie'
description 'CW Racing App'
version '4.2.2'

ui_page {
    "html/dist/index.html"
}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/en.lua',
    'config.lua',
    '@qbx_core/modules/playerdata.lua'
}

client_scripts {
    'bridge/client/*.lua',
    'client/classes.lua',
    'client/functions.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'bridge/server/*.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/crypto.lua',
    'server/crews.lua',
    'server/elo.lua',
    'server/bounties.lua'
}

files {
    "html/dist/index.html",
    "html/dist/assets/*.*",
}

dependencies {
    'cw-performance'
}

lua54 'yes'
