-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Coffeelot & Wuggie'
description 'CW Racing App'
version '3.4.0'

ui_page {
    "html/dist/index.html"
}

shared_scripts {
    'locales/en.lua',
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'bridge/client/*.lua',
    'client/functions.lua',
    'client/main.lua',
} 

server_scripts {
    '@oxmysql/lib/MySQL.lua',
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
    'qb-core',
    'cw-performance'
}

lua54 'yes'
