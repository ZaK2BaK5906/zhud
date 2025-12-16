fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ZaK'
description 'ZK HUD V2 - Ultra Customizable HUD with Multi-Framework Support'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'oxmysql',
    'ox_lib'
}
