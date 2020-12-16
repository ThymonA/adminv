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

local __print = print

AdminV = {
    __class = 'adminv',
    Modules = {
        __class = 'modules',
        Loaded = false,
        Categories = {},
        Infos = {},
        Modules = {}
    },
    Environments = {
        __class = 'environments',
        Modules = {},
        Natives = nil
    },
    General = {
        __class = 'general',
        ResourceName = GetCurrentResourceName(),
        IsServer = IsDuplicityVersion(),
        Environment = IsDuplicityVersion() and 'server' or 'client',
        EnableTimestamp = false
    },
    Statics = {
        __class = 'statics',
        MenuVPositions = { 'topleft', 'topcenter', 'topright', 'centerleft', 'center', 'centerright', 'bottomleft', 'bottomcenter', 'bottomright' },
        MenuVSizes = { 'size-100', 'size-110', 'size-125', 'size-150', 'size-175', 'size-200' },
        MenuVThemes = { 'default', 'native' }
    },
    Menu = nil
}

function AdminV.Modules:LoadData()
    if (self.Loaded) then return end

    local categories_json = AdminV.General:LoadJsonFile('modules/categories.json')

    for k, v in pairs(categories_json) do
        v = type(v) == 'string' and v or 'unknown'

        if (self.Categories == nil) then self.Categories = {} end

        local idx = #self.Categories + 1

        self.Categories[idx] = {
            name = v,
            modules = {}
        }

        local category_modules_json = AdminV.General:LoadJsonFile(('modules/%s/modules.json'):format(v))

        for mk, mv in pairs(category_modules_json) do
            mv = type(mv) == 'string' and mv or 'unknown'

            local category_module_path = ('modules/%s/%s'):format(v, mv)
            local has_manifest = LoadResourceFile(AdminV.General.ResourceName, ('%s/manifest.json'):format(category_module_path)) ~= nil

            if (has_manifest) then
                table.insert(self.Categories[idx].modules, {
                    name = mv,
                    directory = category_module_path,
                    category = v
                })
            end
        end
    end

    self.Loaded = true
end

function AdminV.Modules:Load()
    Citizen.CreateThread(function()
        self:LoadData()

        for k, v in pairs(self.Categories) do
            v = type(v) == 'table' and v or {}

            for mk, mv in pairs(v.modules or {}) do
                mv = type(mv) == 'table' and mv or {}

                self:LoadModule(mv.name)
            end
        end
    end)
end

function AdminV.Modules:LoadModule(name)
    if (self.Modules == nil) then self.Modules = {} end

    local module_name = type(name) == 'string' and name or 'unknown'
    local module_info = self:GetInfo(module_name)
    local m_name = type(module_info.NAME) == 'string' and module_info.NAME or 'unknown'

    if (self.Modules[m_name] ~= nil) then return self.Modules[m_name], m_name end

    local m_directory = type(module_info.DIRECTORY) == 'string' and module_info.DIRECTORY or 'unknown'
    local m_environment = AdminV.Environments:Load(m_name)
    local has_current, has_shared, current_files, shared_files = self:IsRunnable(m_name)
    local m_success, m_has_error = true, false

    if (has_shared) then
        for fk, fv in pairs(shared_files) do
            fv = type(fv) == 'string' and fv or 'unknown'

            m_environment, m_success, m_has_error = AdminV.Environments:ExecuteFile(
                nil, ('%s/%s'):format(m_directory, fv), m_environment)

            if (not m_success) then
                if (not m_has_error) then
                    AdminV.General:PrintError(m_environment, ("Failed to load '%s'"):format(fv))
                end

                return nil, nil
            end
        end
    end

    if (has_current) then
        for fk, fv in pairs(current_files) do
            fv = type(fv) == 'string' and fv or 'unknown'

            m_environment, m_success, m_has_error = AdminV.Environments:ExecuteFile(
                nil, ('%s/%s'):format(m_directory, fv), m_environment)

            if (not m_success) then
                if (not m_has_error) then
                    AdminV.General:PrintError(m_environment, ("Failed to load '%s'"):format(fv))
                end

                return nil, nil
            end
        end
    end

    AdminV.Environments.Modules[m_name] = m_environment
    AdminV.General:PrintSuccess(m_environment, 'Successfully loaded!')

    return self.Modules[m_name] or nil, m_name
end

function AdminV.Modules:GetInfo(name)
    name = type(name) == 'string' and name or 'unknown'
    name = string.lower(name)

    if (self.Infos == nil) then self.Infos = {} end
    if (self.Infos[name] ~= nil) then return self.Infos[name] end

    for k, v in pairs(self.Categories) do
        v = type(v) == 'table' and v or {}

        for mk, mv in pairs(v.modules or {}) do
            mv = type(mv) == 'table' and mv or {}

            local module_name = type(mv.name) == 'string' and mv.name or 'unknown'
            local module_directory = type(mv.directory) == 'string' and mv.directory or 'unknown'

            if (string.lower(module_name) == name) then
                ---@class manifest
                local manifest = {}
                local raw_manifest = AdminV.General:LoadJsonFile(('%s/manifest.json'):format(module_directory))

                manifest.name = module_name
                manifest.version = type(raw_manifest.version) == 'string' and raw_manifest.version or '1.0.0'
                manifest.description = type(raw_manifest.description) == 'string' and raw_manifest.description or ''
                manifest.authors = {}
                manifest.files = {}
                manifest.client_scripts = {}
                manifest.server_scripts = {}
                manifest.shared_scripts = {}

                local authors = type(raw_manifest.authors) == 'table' and raw_manifest.authors or {}
                local files = type(raw_manifest.files) == 'table' and raw_manifest.files or {}
                local client_scripts = type(raw_manifest.client_scripts) == 'table' and raw_manifest.client_scripts or {}
                local server_scripts = type(raw_manifest.server_scripts) == 'table' and raw_manifest.server_scripts or {}
                local shared_scripts = type(raw_manifest.shared_scripts) == 'table' and raw_manifest.shared_scripts or {}

                for _k, _v in pairs(authors) do
                    table.insert(manifest.authors, {
                        name = type(_v.name) == 'string' and _v.name or 'unknown',
                        github = type(_v.github) == 'string' and _v.github or 'unknown',
                        discord = type(_v.discord) == 'string' and _v.discord or 'unknown',
                        email = type(_v.email) == 'string' and _v.email or 'unknown'
                    })
                end

                for _k, _v in pairs(files) do
                    local value = type(_v) == 'string' and _v or nil

                    if (value) then table.insert(manifest.files, value) end
                end

                for _k, _v in pairs(client_scripts) do
                    local value = type(_v) == 'string' and _v or nil

                    if (value) then table.insert(manifest.client_scripts, value) end
                end

                for _k, _v in pairs(server_scripts) do
                    local value = type(_v) == 'string' and _v or nil

                    if (value) then table.insert(manifest.server_scripts, value) end
                end

                for _k, _v in pairs(shared_scripts) do
                    local value = type(_v) == 'string' and _v or nil

                    if (value) then table.insert(manifest.shared_scripts, value) end
                end

                local category_name = type(v.name) == 'string' and v.name or 'unknown'
                local is_server = AdminV.General.IsServer and true or false

                ---@class module_info
                local module_info = {
                    NAME = module_name,
                    CATEGORY = category_name,
                    DIRECTORY = module_directory,
                    RESOURCE = AdminV.General.ResourceName,
                    KEY = ('%s:%s'):format(category_name, module_name),
                    MANIFEST = manifest,
                    ENVIRONMENT = is_server and 'server' or 'client',
                    SERVER = is_server,
                    CLIENT = not is_server
                }

                self.Infos[name] = module_info

                return module_info
            end
        end
    end

    return {}
end

function AdminV.Modules:IsRunnable(name)
    name = type(name) == 'string' and name or 'unknown'

    local module_info = self:GetInfo(name)
    local manifest = type(module_info.MANIFEST) == 'table' and module_info.MANIFEST or {}
    local shared_scripts = type(manifest.shared_scripts) == 'table' and manifest.shared_scripts or {}

    if (AdminV.General.IsServer) then
        local server_scripts = type(manifest.server_scripts) == 'table' and manifest.server_scripts or {}

        return #server_scripts > 0, #shared_scripts > 0, server_scripts, shared_scripts
    end

    local client_scripts = type(manifest.client_scripts) == 'table' and manifest.client_scripts or {}

    return #client_scripts > 0, #shared_scripts > 0, client_scripts, shared_scripts
end

function AdminV.Modules:GetModules()
    self:LoadData()

    local _modules = {}

    for k, v in pairs(self.Categories) do
        v = type(v) == 'table' and v or {}

        for mk, mv in pairs(v.modules or {}) do
            mv = type(mv) == 'table' and mv or {}

            local m_name = type(mv.name) == 'string' and mv.name or 'unknown'
            local m_directory = type(mv.directory) == 'string' and mv.directory or 'unknown'
            local m_category = type(mv.category) == 'string' and mv.category or 'unknown'

            _modules[m_name] = {
                name = m_name,
                directory = m_directory,
                category = m_category
            }
        end
    end

    return _modules
end

function AdminV.Environments:LoadNatives()
    if (self.Natives == nil) then
        self.Natives = {}

        local natives = AdminV.General:LoadJsonFile(('natives/natives_%s.json'):format(AdminV.General.Environment))

        for k, v in pairs(natives) do
            self.Natives[v] = _G[v]
        end
    end
end

function AdminV.Environments:Create(env)
    env = type(env) == 'table' and env or {}

    local newEnvironment = {}

    for k, v in pairs(self.Natives or {}) do newEnvironment[k] = v end
    for k, v in pairs(_G) do newEnvironment[k] = v end
    for k, v in pairs(_ENV) do newEnvironment[k] = v end
    for k, v in pairs(env) do newEnvironment[k] = v end

    local code = LoadResourceFile(AdminV.General.ResourceName, 'shared/environment.lua')

    newEnvironment.RegisterModule = function(env, module)
        env = type(env) == 'table' and env or {}
        module = module ~= nil and module or {}

        local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
        local module_env = self:Load(module_name)

        module_name = type(module_env.NAME) == 'string' and module_env.NAME or module_name

        if (AdminV.Modules.Modules == nil) then AdminV.Modules.Modules = {} end

        if (type(module) == 'table') then
            rawset(module, '__init', function(env)
                rawset(module_env, '_PARENT', env)
                rawset(module_env, '_ENV', module_env)
                rawset(module_env, '_G', module_env)
            end)
        end

        AdminV.Modules.Modules[module_name] = module
    end

    newEnvironment.M = function(env, ...)
        local _modules = { ... }

        env = type(env) == 'table' and env or {}

        for k, v in pairs(_modules) do
            v = type(v) == 'string' and v or 'unknown'

            local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
            local loaded_module = AdminV.Modules:LoadModule(v)

            if (loaded_module) then
                local module_env = self:Load(module_name)

                if (type(loaded_module) == 'table') then
                    local __init = rawget(loaded_module, '__init')

                    if (__init ~= nil and type(__init) == 'function') then
                        __init(module_env)
                    end
                end

                rawset(newEnvironment, v, loaded_module)
                rawset(module_env, v, loaded_module)
            end
        end
    end

    newEnvironment.print = function(env, ...)
        env = type(env) == 'table' and env or {}

        local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
        local module_env = self:Load(module_name)

        AdminV.General:Print(module_env, ...)
    end

    newEnvironment.print_error = function(env, ...)
        env = type(env) == 'table' and env or {}

        local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
        local module_env = self:Load(module_name)

        AdminV.General:PrintError(module_env, ...)
    end

    newEnvironment.print_success = function(env, ...)
        env = type(env) == 'table' and env or {}

        local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
        local module_env = self:Load(module_name)

        AdminV.General:PrintSuccess(module_env, ...)
    end

    newEnvironment.print_warning = function(env, ...)
        env = type(env) == 'table' and env or {}

        local module_name = type(env.NAME) == 'string' and env.NAME or 'unknown'
        local module_env = self:Load(module_name)

        AdminV.General:PrintWarning(module_env, ...)
    end

    newEnvironment.GetModules = function()
        return AdminV.Modules:GetModules()
    end

    newEnvironment.GetInvokingModules = function()
        local modules = AdminV.Modules:GetModules()
        local resource_name = AdminV.General.ResourceName or GetCurrentResourceName() or 'unknown'
        local index, current_debug, invking_modules = 0, nil, {}

        while (index <= 0 or current_debug ~= nil) do
            index = index + 1

            current_debug = debug.getinfo(index)

            if (current_debug ~= nil) then
                local s = current_debug.source ~= nil and tostring(current_debug.source) or 'unknown'

                if (s ~= 'unknown') then
                    while (s:sub(1, 1) == '@') do
                        s = s:sub(2)
                    end

                    local prefix = ('%s:'):format(resource_name)

                    if (s:sub(1, #prefix) == prefix) then
                        local module_path = s:sub(#prefix + 1)

                        for k, v in pairs(modules) do
                            local m_dir = type(v.directory) == 'string' and v.directory or 'unknown'
                            local m_name = type(v.name) == 'string' and v.name or 'unknown'

                            if (module_path:sub(1, #m_dir) == m_dir) then
                                table.insert(invking_modules, m_name)
                            end
                        end
                    end
                end
            end

            if (#invking_modules >= 2) then
                return invking_modules
            end
        end

        return invking_modules
    end

    newEnvironment.AddMenuOption = function(option)
        if (AdminV.Menu and MenuV) then
            option = type(option) == 'table' and option or {}

            local config, translations = LoadModule('config', 'translations')
            local settings = config('settings')
            local admin_subtitle = translations('core'):T('admin_subtitle')
            local subtitle = type(option.subtitle) == 'string' and option.subtitle or tostring(option.subtitle or '') or ''

            if (subtitle ~= nil and subtitle ~= '') then
                subtitle = ('%s > %s'):format(admin_subtitle, subtitle)
            end

            local sub_menu = MenuV:CreateMenu(
                type(option.title) == 'string' and option.title or tostring(option.title) or 'unknown',
                subtitle,
                settings.position or 'topleft',
                (settings.color or {}).r or 255,
                (settings.color or {}).g or 0,
                (settings.color or {}).b or 0,
                settings.size or 'size-125',
                type(option.texture) == 'string' and option.texture or (AdminV.Menu or {}).Texture or 'default',
                type(option.dictionary) == 'string' and option.dictionary or (AdminV.Menu or {}).Dictionary or 'menuv',
                ('adminv_%s'):format(newEnvironment.GetInvokingModule() or 'unknown'),
                settings.theme or 'native')

            AdminV.Menu:AddButton({
                icon = type(option.icon) == 'string' and option.icon or tostring(option.icon or '') or '',
                label = type(option.title) == 'string' and option.title or tostring(option.title) or 'unknown',
                description = type(option.description) == 'string' and option.description or tostring(option.description or '') or '',
                value = sub_menu
            })

            return sub_menu
        end
    end

    newEnvironment.GetInvokingModule = function()
        local invoking_modules = newEnvironment.GetInvokingModules()

        invoking_modules = type(invoking_modules) == 'table' and invoking_modules or {}

        if (#invoking_modules > 0) then
            local idx = 1

            if (#invoking_modules >= 2) then idx = 2 end

            local invoking_module = invoking_modules[idx]

            return type(invoking_module) == 'string' and invoking_module or 'unknown'
        end

        return 'unknown'
    end

    if (code) then
        local fn = load(code, 'environment:create')

        if (fn) then
            local ok, result = xpcall(fn, function(msg)
                AdminV.General:PrintError(newEnvironment, msg)
            end)

            if (ok) then
                return result(newEnvironment, _G) or newEnvironment
            end
        end
    end

    return newEnvironment
end

function AdminV.Environments:ExecuteFile(resource, file, env)
    resource = type(resource) == 'string' and resource or AdminV.General.ResourceName
    file = type(file) == 'string' and file or 'unknown'
    env = type(env) == 'table' and env or self:Create()

    local has_error, code = false, LoadResourceFile(resource, file)

    if (code) then
        local fn = load(code, ('@%s:%s'):format(resource, file), 't', env)

        if (fn) then
            local ok = xpcall(fn, function(msg)
                has_error = true
                AdminV.General:PrintError(env, msg)
            end)

            if (ok) then
                return env, true, has_error
            end
        end
    end

    return env, false, has_error
end

function AdminV.Environments:Load(name)
    name = type(name) == 'string' and name or 'unknown'

    if (self.Modules == nil) then self.Modules = {} end

    local module_info = AdminV.Modules:GetInfo(name)
    local module_name = type(module_info.NAME) == 'string' and module_info.NAME or 'unknown'

    if (self.Modules[module_name] ~= nil) then return self.Modules[module_name] end

    local env = self:Create(module_info)

    self.Modules[module_name] = env

    return env
end

function AdminV.General:LoadJsonFile(file)
    file = type(file) == 'string' and file or 'unknown'

    local raw_data = LoadResourceFile(self.ResourceName, file)

    if (raw_data) then
        local json_data = json.decode(raw_data)

        return type(json_data) == 'table' and json_data or {}
    end

    return {}
end

function AdminV.General:GetTimestamp()
    local timestamp = ''

    if (not self.EnableTimestamp) then
        return timestamp
    end

    if (os ~= nil and os.date ~= nil) then
        local date_table = os.date("*t")
        local hour, minute, second = date_table.hour, date_table.min, date_table.sec
        local year, month, day = date_table.year, date_table.month, date_table.day

        hour, minute, second = tostring(hour), tostring(minute), tostring(second)
        year, month, day = tostring(year), tostring(month), tostring(day)

        hour = string.len(hour) >= 2 and hour or ('0%s'):format(hour)
        minute = string.len(minute) >= 2 and minute or ('0%s'):format(minute)
        second = string.len(second) >= 2 and second or ('0%s'):format(second)
        month = string.len(month) >= 2 and month or ('0%s'):format(month)
        day = string.len(day) >= 2 and day or ('0%s'):format(day)

        local result = string.format("%s-%s-%s %s:%s:%s", year, month, day, hour, minute, second)

        timestamp = ('^7%s '):format(result)
    end

    return timestamp
end

function AdminV.General:PrintError(env, msg)
    env = env or AdminV.Environments:Create()
    msg = type(msg) == 'string' and msg or (tostring(msg) or 'unknown')

    local timestamp = self:GetTimestamp()
    local name = (type(env.NAME) == 'string' and ('^7[^5%s^7]'):format(env.NAME)) or ''
    local category = (type(env.CATEGORY) == 'string' and ('^7[^4%s^7]'):format(env.CATEGORY:sub(-2) == '__' and env.CATEGORY:sub(1, 2) == '__' and env.CATEGORY:sub(3, #(env.CATEGORY) -2) or env.CATEGORY)) or ''
    local fst = Citizen.InvokeNative(-0x28F3C436 & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())
    local error_message = nil
    local start_index, end_index = msg:find(':%d+:')

    if (start_index and end_index) then
        msg = ('%s^7 line^1:^7%s^7\n\n^1%s\n'):format(
            msg:sub(1, start_index - 1),
            msg:sub(start_index + 1, end_index - 1),
            msg:sub(end_index + 1)
        )
    end

    if (not fst) then
        error_message = ('%s^7[^6AdminV^7][^1ERROR^7]%s^7%s %s^7'):format(timestamp, category, name, msg)
    else
        error_message = ('%s^7[^6AdminV^7][^1ERROR^7]%s%s ^7%s\n^7%s^7'):format(timestamp, category, name, msg, fst)
    end

    __print(error_message)
end

function AdminV.General:Print(env, ...)
    env = env or AdminV.Environments:Create()

    local args = { ... }
    local timestamp = self:GetTimestamp()
    local category = (type(env.CATEGORY) == 'string' and ('^7[^4%s^7]'):format(env.CATEGORY:sub(-2) == '__' and env.CATEGORY:sub(1, 2) == '__' and env.CATEGORY:sub(3, #(env.CATEGORY) -2) or env.CATEGORY)) or ''
    local str = ("^7[INFO]%s[^5%s^7]"):format(category, env.NAME)

    for i = 1, #args, 1 do
        str = ('%s %s'):format(str, tostring(args[i]))
    end

    __print(('%s^7[^6AdminV^7]%s'):format(timestamp, str))
end

function AdminV.General:PrintSuccess(env, ...)
    env = env or AdminV.Environments:Create()

    local args = { ... }
    local timestamp = self:GetTimestamp()
    local category = (type(env.CATEGORY) == 'string' and ('^7[^4%s^7]'):format(env.CATEGORY:sub(-2) == '__' and env.CATEGORY:sub(1, 2) == '__' and env.CATEGORY:sub(3, #(env.CATEGORY) -2) or env.CATEGORY)) or ''
    local str = ("^7[^2SUCCESS^7]%s[^5%s^7]"):format(category, env.NAME)

    for i = 1, #args, 1 do
        str = ('%s %s'):format(str, tostring(args[i]))
    end

    __print(('%s^7[^6AdminV^7]%s'):format(timestamp, str))
end

function AdminV.General:PrintWarning(env, ...)
    env = env or AdminV.Environments:Create()

    local args = { ... }
    local timestamp = self:GetTimestamp()
    local category = (type(env.CATEGORY) == 'string' and ('^7[^4%s^7]'):format(env.CATEGORY:sub(-2) == '__' and env.CATEGORY:sub(1, 2) == '__' and env.CATEGORY:sub(3, #(env.CATEGORY) -2) or env.CATEGORY)) or ''
    local str = ("^7[^3WARN^7]%s[^5%s^7]"):format(category, env.NAME)

    for i = 1, #args, 1 do
        str = ('%s %s'):format(str, tostring(args[i]))
    end

    __print(('%s^7[^6AdminV^7]%s'):format(timestamp, str))
end

function LoadAdminV()
    AdminV.Modules:Load()
end

function LoadModule(...)
    local results = {}
    local args = { ... }

    for k, v in pairs(args) do
        v = type(v) == 'string' and v or 'unknown'

        table.insert(results, AdminV.Modules:LoadModule(v) or nil)
    end

    return table.unpack(results)
end

print = function(...)
    AdminV.General:Print(_ENV, ...)
end

print_error = function(...)
    AdminV.General:PrintError(_ENV, ...)
end

print_success = function(...)
    AdminV.General:PrintSuccess(_ENV, ...)
end

print_warning = function(...)
    AdminV.General:PrintWarning(_ENV, ...)
end

Citizen.CreateThread(function()
    AdminV.Environments:LoadNatives()
end)