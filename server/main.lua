--[[
    Copyright © 2020 ThymonA

    Name:           AdminV
    Version:        1.0.0
    Description:    FiveM Admin Menu by ThymonA
    GitHub:         https://github.com/ThymonA/adminv/
    Author:         Thymon Arens <contact@arens.io>
    License:        GNU General Public License v3.0
                    https://choosealicense.com/licenses/gpl-3.0/
                    You should have received a copy of the GNU General Public License
                    along with this resource. If not, see <https://choosealicense.com/licenses/gpl-3.0/>
]]

LoadAdminV()

AddEventHandler('playerConnecting', function(playerName, _, deferrals)
    local player_src = source

    deferrals.defer()

    local config, events, translations = LoadModule('config', 'events', 'translations')
    local translation = translations('core')

    if (events == nil) then
        deferrals.done(translation:T('on_connecting_error'))
        return
    end

    local printConnectingMessage = config('core').print_connecting_messages or true

    if (printConnectingMessage) then
        print(('^7[^6AdminV^7]^7[INFO] %s'):format(translation:T('player_connecting', playerName)))
    end

    events:triggerPlayerConnecting(playerName, player_src, deferrals)
end)

RegisterServerEvent('menuv:loadAdminV')
AddEventHandler('menuv:loadAdminV', function()
    local source = source
    local utils, permissions = LoadModule('utils', 'permissions')

    source = utils:ensure(source, -1)

    if (source <= 0) then
        return
    end

    TriggerClientEvent('menuv:loadAdminV', source, permissions(source))
end)