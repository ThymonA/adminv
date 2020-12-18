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

AdminV.Permissions = {
    Access = false,
    ServerManagement = {
        StartResource = false,
        StopResource = false,
        RestartResource = false
    },
    PlayerManagement = {
        AllPlayers = {},
        TargetPlayer = {
            Kick = false,
            Ban = false,
            Spectate = false,
            TeleportTo = false,
            TeleportToMe = false,
            PermBan = false,
            Warn = false,
            Freeze = false,
            Screenshot = false
        }
    }
}

Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            TriggerServerEvent('adminv:loadAdminV')
            break
        end

        Citizen.Wait(250)
    end
end)

RegisterNetEvent('adminv:loadAdminV')
AddEventHandler('adminv:loadAdminV', function(permissions)
    AdminV.Permissions = permissions

    if (permissions.Access) then
        AdminV.Modules:LoadData()

        local config, utils, translations = LoadModule('config', 'utils', 'translations')
        local core = config('core')
        local settings = config('settings')
        local trans = translations('core')

        AdminV.Menu = MenuV:CreateMenu(
            utils:ensure(core.menu_title, 'AdminV'),
            trans:T('admin_subtitle'),
            utils:ensure(settings.position, 'topleft'),
            utils:ensure((settings.color or {}).r, 255),
            utils:ensure((settings.color or {}).g, 0),
            utils:ensure((settings.color or {}).b, 0),
            utils:ensure(settings.size, 'size-125'),
            utils:ensure(core.menu_texture, 'default'),
            utils:ensure(core.menu_dictionary, 'menuv'),
            'adminv',
            utils:ensure(settings.theme, 'native')
        )

        AdminV.Menu:OpenWith('keyboard', utils:ensure(core.menu_open_with, 'OEM_3'))

        LoadAdminV()
    end
end)