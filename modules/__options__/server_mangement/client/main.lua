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

M('utils', 'config', 'translations')

local trans = translations()

if (not utils:any(true, (AdminV.Permissions or {}).ServerManagement or {}, 'value')) then
    return
end

local server_management_menu = AddMenuOption({
    icon = '🧰',
    title = trans:T('server_management'),
    subtitle = trans:T('server_management'),
    description = trans:T('server_management_description')
})

if (((AdminV.Permissions or {}).ServerManagement or {}).StartResource) then
    AddStartResourceOption(server_management_menu, trans)
end

if (((AdminV.Permissions or {}).ServerManagement or {}).StopResource) then
    AddStopResourceOption(server_management_menu, trans)
end