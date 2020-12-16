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
    Access = false
}

Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            TriggerServerEvent('menuv:loadAdminV')
            break
        end

        Citizen.Wait(250)
    end
end)

RegisterNetEvent('menuv:loadAdminV')
AddEventHandler('menuv:loadAdminV', function(permissions)
    AdminV.Permissions = permissions

    if (permissions.Access) then
        LoadAdminV()
    end
end)