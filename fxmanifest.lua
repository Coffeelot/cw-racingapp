-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Coffeelot, Wuggie'
description 'Racing App for QB'
version '1.0.0'

ui_page {
    "html/dist/index.html"
}

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    '@ox_lib/init.lua',
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
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
