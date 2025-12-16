fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ZaK'
description 'ZK HUD V3 - Ultra Customizable HUD with Drag & Drop'
version '3.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependency 'oxmysql'
