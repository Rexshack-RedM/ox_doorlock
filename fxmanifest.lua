fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

name 'ox_doorlock'
description 'doorlock system for RSG RedM Framework'
version '2.0.2'
license 'GPL-3.0-or-later'
author 'Overextended & RSG'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/utils.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/versionchecker.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
}

dependencies {
    'oxmysql',
    'ox_lib',
}

ox_libs {
    'locale',
    'table',
}
