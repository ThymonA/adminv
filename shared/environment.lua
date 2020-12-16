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

local environment = {
    NAME = 'unknown',
    CATEGORY = 'unknown',
    DIRECTORY = 'unknown',
    KEY = 'unknown:unknown',
    RESOURCE = 'adminv',
    ENVIRONMENT = 'shared',
    MANIFEST = nil,
    SERVER = false,
    CLIENT = false
}

return setmetatable({ __class = 'environment' }, {
    __index = function(t, k)
        local key = type(k) == 'string' and k or tostring(k) or ''
        key = string.lower(key)

        if (key == '__init') then return nil end

        return rawget(environment, k)
    end,
    __newindex = function(t, k, v)
        k = type(k) == 'string' and k or tostring(k) or ''
        k = string.lower(k)

        if (k == 'name' or k == 'category' or k == 'directory' or k == 'key' or k == 'manifest' or k == '__init' or k == 'environment' or k == 'server' or k == 'client') then
            return
        end

        rawset(environment, k, v)
    end,
    __call = function(t, env)
        env = type(env) == 'table' and env or {}

        for k, v in pairs(env) do
            local key = string.lower(type(k) == 'string' and k or 'unknown')

            if (key == 'name' or key == 'category' or key == 'directory' or key == 'key' or key == 'manifest' or key == 'environment' or key == 'server' or key == 'client') then
                k = string.upper(k)
            end

            rawset(environment, k, v)
        end

        for k, v in pairs(environment or {}) do
            local key = type(k) == 'string' and k or 'unknown'

            if (key == 'RegisterModule') then
                rawset(environment, '__RegisterModule', v)
                rawset(environment, 'RegisterModule', function(module)
                    local func = rawget(environment, '__RegisterModule')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, module)
                end)
            end

            if (key == 'M') then
                rawset(environment, '__M', v)
                rawset(environment, 'M', function(...)
                    local func = rawget(environment, '__M')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, ...)
                end)
            end

            if (key == 'print') then
                rawset(environment, '__print', v)
                rawset(environment, 'print', function(...)
                    local func = rawget(environment, '__print')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, ...)
                end)
            end

            if (key == 'print_error') then
                rawset(environment, '__print_error', v)
                rawset(environment, 'print_error', function(...)
                    local func = rawget(environment, '__print_error')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, ...)
                end)
            end

            if (key == 'print_success') then
                rawset(environment, '__print_success', v)
                rawset(environment, 'print_success', function(...)
                    local func = rawget(environment, '__print_success')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, ...)
                end)
            end

            if (key == 'print_warning') then
                rawset(environment, '__print_warning', v)
                rawset(environment, 'print_warning', function(...)
                    local func = rawget(environment, '__print_warning')

                    func = type(func) == 'function' and func or function() end

                    return func(environment, ...)
                end)
            end
        end

        rawset(environment, '_ENV', environment)
        rawset(environment, '_G', environment)
        rawset(environment, '_PARENT', environment)

        return environment
    end,
    __pairs = function(t)
        return pairs(type(environment) == 'table' and environment or {})
    end
})