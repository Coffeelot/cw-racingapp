-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Coffeelot & Wuggie'
description 'CW Racing App'
version '3.5.4'

ui_page {
    "html/dist/index.html"
}

shared_scripts {
    '@ox_lib/init.lua',
    'locales/en.lua',
    'shared/config.lua',
    'shared/head2head.lua',
}

client_scripts {
    'bridge/client/*.lua',
    'client/classes.lua',
    'client/functions.lua',
    'client/main.lua',
    'client/head2head.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/debug.lua',
    'server/database.lua',
    'bridge/server/*.lua',
    'server/functions.lua',
    'server/main.lua',
    'server/crypto.lua',
    'server/crews.lua',
    'server/elo.lua',
    'server/bounties.lua',
    'server/head2head.lua'
}

files {
    "html/dist/index.html",
    "html/dist/assets/*.*",
}

dependencies {
    'cw-performance'
}

lua54 'yes'
