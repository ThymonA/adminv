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

local permissions = { __class = 'permissions' }

RegisterModule(setmetatable(permissions, {
    __index = function(t, k)
        return type(AdminV.Permissions) == 'table' and AdminV.Permissions or {}
    end,
    __newindex = function(t, k, v)
        error('cannot set values on permissions')
    end,
    __call = function(t, k)
        return type(AdminV.Permissions) == 'table' and AdminV.Permissions or {}
    end
}))