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

M('utils')

local stored_permissions = {}
local permissions = { __class = 'permissions' }

local function load_permissions(source)
    source = utils:ensure(source, -1)

    if (stored_permissions[tostring(source)] ~= nil) then
        return stored_permissions[tostring(source)]
    end

    local source_perms = {
        Access = IsPlayerAceAllowed(source, 'AdminV.Access'),
        ServerManagement = {
            StartResource = IsPlayerAceAllowed(source, 'AdminV.ServerManagement.StartResource'),
            StopResource = IsPlayerAceAllowed(source, 'AdminV.ServerManagement.StopResource')
        }
    }

    stored_permissions[tostring(source)] = source_perms

    return source_perms
end

RegisterModule(setmetatable(permissions, {
    __index = function(t, k)
        return load_permissions(k)
    end,
    __newindex = function(t, k, v)
        error('cannot set values on permissions')
    end,
    __call = function(t, k)
        return load_permissions(k)
    end
}))