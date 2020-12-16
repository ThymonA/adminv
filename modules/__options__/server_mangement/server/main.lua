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

M('utils', 'permissions')

AddGlobalEventHandler('adminv:server_mangement:stopResource', function(source, name)
    name = utils:ensure(name, 'unknown')
    source = utils:ensure(source, -1)

    local perms = permissions(source)

    if ((perms.ServerManagement or {}).StopResource) then
        ExecuteCommand(('stop %s'):format(name))
    end
end)

AddGlobalEventHandler('adminv:server_mangement:startResource', function(source, name)
    name = utils:ensure(name, 'unknown')
    source = utils:ensure(source, -1)

    local perms = permissions(source)

    if ((perms.ServerManagement or {}).StartResource) then
        ExecuteCommand(('start %s'):format(name))
    end
end)