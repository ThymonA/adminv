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

local stored_events = {}
local events = {}

M('utils', 'config', 'translations')

local trans = translations()

local function onEvent(module, event, name, func)
    module = utils:ensure(module, NAME or 'unknown')
    event = utils:ensure(event, 'unknown')
    name = utils:ensure(name, utils:typeof(name) == 'table' and {} or 'unknown')

    if (utils:typeof(name) == 'table') then
        for k, v in pairs(name) do
            if (utils:typeof(v) == 'string') then
                onEvent(module, event, v, func)
            end
        end

        return
    end

    event = string.lower(event)
    name = name ~= 'unknown' and string.lower(name) or nil

    if (stored_events == nil) then stored_events = {} end
    if (stored_events[event] == nil) then
        stored_events[event] = {
            triggers = {},
            parameters = {}
        }
    end

    if (name == nil) then
        table.insert(stored_events[event].triggers, {
            module = module,
            func = func
        })
    else
        if (stored_events[event].parameters[name] == nil) then
            stored_events[event].parameters[name] = {}
        end

        table.insert(stored_events[event].parameters[name], {
            module = module,
            func = func
        })
    end
end

local function filterArguments(...)
    local name, names, callback = nil, nil, nil
    local name_i, names_i, index = 999, 999, 0
    local arguments = {...}

    for k, v in pairs(arguments) do
        index = index + 1

        local t = utils:typeof(v)

        if (t == 'function' and callback == nil) then
            callback = v
        elseif (t == 'table' and names == nil) then
            for nk, nv in pairs(v) do
                local n = utils:ensure(nv, 'unknown')

                if (n ~= 'unknown') then
                    if (names == nil) then
                        names = {}
                        names_i = index
                    end

                    table.insert(names, n)
                end
            end
        elseif (name == nil) then
            local n = utils:ensure(v, 'unknown')

            if (n ~= 'unknown') then
                name = n
                name_i = index
            end
        end
    end

    if (name ~= nil and callback ~= nil and name_i < names_i) then
        return callback, name
    elseif (names ~= nil and callback ~= nil and names_i < name_i) then
        return callback, names
    elseif (callback ~= nil) then
        return callback, nil
    end

    return nil, nil
end

function events:on(event, ...)
    event = utils:ensure(event, 'unknown')

    local module = utils:ensure(GetInvokingModule(), NAME or 'unknown')
    local callback, name = filterArguments(...)

    if (callback == nil) then return end

    onEvent(module, event, name, callback)
end

function events:anyEventRegistered(event, param)
    event = utils:ensure(event, 'unknown')

    if (event == 'unknown' or stored_events == nil) then return false end

    if (stored_events[event] ~= nil) then
        if (param == nil or type(param) == 'function') then return stored_events[event].triggers > 0 end

        local param_s = utils:ensure(param, 'none')

        for k, v in pairs(stored_events[event].parameters) do
            local p = utils:ensure(k, 'unknown')
            local i = utils:ensure(k, param, true)

            if (i == param or p == param_s) then
                return true
            end
        end
    end

    return false
end

function events:getEventRegistered(event, param)
    local registered_events = {}

    event = utils:ensure(event, 'unknown')
    event = string.lower(event)

    if (event == 'unknown' or stored_events == nil) then return {} end

    if (stored_events[event] ~= nil) then
        for k, v in pairs(stored_events[event].triggers) do
            local f = utils:ensure(v.func, function() end)

            table.insert(registered_events, f)
        end

        if (param ~= nil and type(param) ~= 'function') then
            local param_s = utils:ensure(param, 'none')

            for k, v in pairs(stored_events[event].parameters) do
                local p = utils:ensure(k, 'unknown')
                local i = utils:ensure(k, param, true)

                if (i == param or p == param_s) then
                    local f = utils:ensure(v.func, function() end)

                    table.insert(registered_events, f)
                end
            end
        end
    end

    return registered_events
end

function events:triggerOnEvent(event, name, ...)
    local registered_events = self:getEventRegistered(event, name)
    local params = table.pack(...)

    for k, v in pairs(registered_events) do
        Citizen.CreateThread(function()
            v = utils:ensure(v, function() end)

            utils:try(function()
                v(table.unpack(params))
            end, print_error)
        end)
    end
end

if (SERVER) then
    function events:getIdentifiersBySource(source)
        source = utils:ensure(source, -1)

        local tableResults = {
            steam = nil,
            license = nil,
            xbl = nil,
            live = nil,
            discord = nil,
            fivem = nil,
            ip = nil
        }

        if (source < 0 or source == 0) then return tableResults end

        local numIds = GetNumPlayerIdentifiers(source)

        for i = 0, numIds - 1, 1 do
            local identifier = utils:ensure(GetPlayerIdentifier(source, i), 'none')

            if (string.match(identifier, 'steam:')) then
                tableResults.steam = string.sub(identifier, 7)
            elseif (string.match(identifier, 'license:')) then
                tableResults.license = string.sub(identifier, 9)
            elseif (string.match(identifier, 'xbl:')) then
                tableResults.xbl = string.sub(identifier, 5)
            elseif (string.match(identifier, 'live:')) then
                tableResults.live = string.sub(identifier, 6)
            elseif (string.match(identifier, 'discord:')) then
                tableResults.discord = string.sub(identifier, 9)
            elseif (string.match(identifier, 'fivem:')) then
                tableResults.fivem = string.sub(identifier, 7)
            elseif (string.match(identifier, 'ip:')) then
                tableResults.ip = string.sub(identifier, 4)
            end
        end

        return tableResults
    end

    function events:generateCard(title, description, banner)
        local cfgBanner = utils:ensure(config().bannerUrl, 'https://forum.cfx.re/uploads/default/original/4X/f/7/b/f7bd789d9d3ad55ff91dc57979e485e99e1a5273.png')
        local serverName = utils:ensure(config('core').server_name, 'ProjectV')

        local _tit = trans:T('connecting_title', serverName)
        local _desc = trans:T('connecting_description', serverName)

        title = utils:ensure(title, _tit)
        description = utils:ensure(description, _desc)
        banner = utils:ensure(banner, cfgBanner)

        local card = {
            ['type'] = 'AdaptiveCard',
            ['body'] = {
                { type = "Image", url = banner },
                { type = "TextBlock", size = "Medium", weight = "Bolder", text = title, horizontalAlignment = "Center" },
                { type = "TextBlock", text = description, wrap = true, horizontalAlignment = "Center" }
            },
            ['$schema'] = "http://adaptivecards.io/schemas/adaptive-card.json",
            ['version'] = "1.3"
        }

        return json.encode(card)
    end

    function events:getPresentCard(deferrals)
        -- Create a `presentCard` class
        ---@class presentCard
        local presentCard = setmetatable({ __class = 'presentCard' }, {})

        ---@type string
        presentCard.title = nil
        ---@type string
        presentCard.description = nil
        ---@type string
        presentCard.banner = nil
        ---@type table
        presentCard.deferrals = deferrals

        function presentCard:update()
            local cardJson = events:generateCard(self.title, self.description, self.banner)

            self.deferrals.presentCard(cardJson)
        end

        function presentCard:setTitle(title, update)
            title = utils:ensure(title, 'unknown')
            update = utils:ensure(update, true)

            if (title == 'unknown') then title = nil end

            self.title = title

            if (update) then self:update() end
        end

        function presentCard:setDescription(description, update)
            description = utils:ensure(description, 'unknown')
            update = utils:ensure(update, true)

            if (description == 'unknown') then description = nil end

            self.description = description

            if (update) then self:update() end
        end

        function presentCard:setBanner(banner, update)
            banner = utils:ensure(banner, 'unknown')
            update = utils:ensure(update, true)

            if (banner == 'unknown') then banner = nil end

            self.banner = banner

            if (update) then self:update() end
        end

        function presentCard:reset(update)
            update = utils:ensure(update, true)

            self.title = nil
            self.description = nil
            self.banner = nil

            if (update) then self:update() end
        end

        function presentCard:override(card, ...)
            self.deferrals.presentCard(card, ...)
        end

        presentCard:update()

        return presentCard
    end

    function events:triggerPlayerConnecting(name, source, deferrals)
        source = utils:ensure(source, -1)

        if (source <= 0) then
            deferrals.done()
            return
        end

        name = utils:ensure(name, GetPlayerName(source) or 'Unknown')

        local registered_events = self:getEventRegistered('playerConnecting')

        if (#registered_events <= 0) then
            deferrals.done()
            return
        end

        local presentCard = self:getPresentCard(deferrals)
        local identifiers = self:getIdentifiersBySource(source)
        local primary_identifier = utils:ensure(config('core').primary_identifier, 'license')

        local player = {
            source = source,
            name = name,
            identifier = utils:ensure(identifiers[primary_identifier], 'unknown'),
            identifiers = identifiers
        }

        for k, v in pairs(registered_events) do
            local continue, canConnect, rejectMessage = false, false, nil

            presentCard:reset()

            local func = utils:ensure(v, function(_, done, _) done() end)
            local ok = xpcall(func, print_error, player, function(msg)
                msg = utils:ensure(msg, '')
                canConnect = utils:ensure(msg == '', false)

                if (not canConnect) then
                    rejectMessage = msg
                end

                continue = true
            end, presentCard)

            repeat Citizen.Wait(0) until continue == true

            if (not ok) then
                canConnect = false
                rejectMessage = trans:T('connecting_error')
            end

            if (not canConnect) then
                deferrals.done(rejectMessage)
                return
            end
        end

        deferrals.done()
    end
end

RegisterModule(events)