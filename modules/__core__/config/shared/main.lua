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

local stored_configs = {}
local config = { __class = 'config' }

local function load_config(path, config)
    local resource = utils:ensure(RESOURCE, 'unknown')

    path = type(path) == 'string' and path or 'unknown'
    config = type(config) == 'table' and config or {}

    if (resource == 'unknown') then resource = GetCurrentResourceName() end
    if (path == 'unknown') then return config end

    local raw_config = LoadResourceFile(resource, path)

    if (raw_config) then
        local temp_env = {}

        for k, v in pairs(_G) do temp_env[k] = v end
        for k, v in pairs(_ENV) do temp_env[k] = v end

        temp_env.config = config

        local fn = load(raw_config, ('@%s/%s'):format(resource, path), 't', temp_env)

        if (fn) then
            local ok = xpcall(fn, print_error)

            if (ok) then
                return utils:ensure(temp_env.config, config)
            end
        end
    end

    return config
end

function config:LoadConfig(name)
    name = type(name) == 'string' and name or GetInvokingModule() or _PARENT.NAME or NAME or 'unknown'

    if (stored_configs == nil) then stored_configs = {} end
    if (stored_configs[string.lower(name)] ~= nil) then
        return stored_configs[string.lower(name)]
    end

    local directory = ('configs/%s'):format(name)
    local shared_path = ('%s/shared_config.lua'):format(directory)
    local env_path = ('%s/%s_config.lua'):format(directory, ENVIRONMENT)

    local shared_config = load_config(shared_path)
    local env_config = load_config(env_path, shared_config)

    stored_configs[string.lower(name)] = env_config

    return env_config
end

function config:SetValue(name, key, value)
    name = type(name) == 'string' and name or GetInvokingModule() or _PARENT.NAME or NAME or 'unknown'
    key = utils:ensure(key, 'unknown')
    value = value or nil

    if (stored_configs == nil) then
        stored_configs = {}
    end

    if (stored_configs[string.lower(name)] == nil) then
        return
    end

    stored_configs[string.lower(name)][key] = value
end

RegisterModule(setmetatable(config, {
    __index = function(t, k)
        local keyType = utils:typeof(k)

        if (keyType ~= 'string') then
            k = GetInvokingModule() or 'unknown'
        end

        return config:LoadConfig(k)
    end,
    __newindex = function(t, k, v)
        error('cannot set values on config')
    end,
    __call = function(t, k)
        local keyType = utils:typeof(k)

        if (keyType ~= 'string') then
            k = GetInvokingModule() or 'unknown'
        end

        return config:LoadConfig(k)
    end,
    __pairs = function(t)
        return pairs(config:LoadConfig(GetInvokingModule() or 'unknown'))
    end
}))