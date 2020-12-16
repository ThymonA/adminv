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

local utils = { __class = 'utils', __type = 'utils' }

function utils:startsWith(str, word)
    str = self:ensure(str, 'unknown')
    word = self:ensure(word, 'unknown')

    return str:sub(1, #word) == word
end

function utils:endsWith(str, word)
    str = self:ensure(str, 'unknown')
    word = self:ensure(word, 'unknown')

    return str:sub(-#word) == word
end

function utils:split(str, delim)
    str = self:ensure(str, 'unknown')
    delim = self:ensure(delim, 'unknown')

    local t = {}

    for substr in str:gmatch('[^' .. delim .. '^]') do
        substr = self:ensure(substr, '')

        if (#substr > 0) then
            table.insert(t, substr)
        end
    end

    return t
end

function utils:count(str, delim)
    str = self:ensure(str, 'unknown')
    delim = self:ensure(delim, 'unknown')

    local r = self:ensure(self:split(str, delim), {})

    return #r
end

function utils:typeof(input)
    if (input == nil) then return 'nil' end

    local t = type(input)

    if (t ~= 'table') then return t end

    if (rawget(input, '__cfx_functionReference') ~= nil or
        rawget(input, '__cfx_async_retval') ~= nil) then
        return 'function'
    end

    if (rawget(input, '__cfx_functionSource') ~= nil) then
        return 'number'
    end

    local __class = rawget(input, '__class')

    if (__class ~= nil) then
        return type(__class) == 'string' and __class or 'class'
    end

    local __type = rawget(input, '__type')

    if (__type ~= nil) then
        return type(__type) == 'string' and __type or '__type'
    end

    return t
end

function utils:ensure(input, default, ignoreDefault)
    if (ignoreDefault == nil) then
        ignoreDefault = false
    else
        ignoreDefault = self:ensure(ignoreDefault, false)
    end

    if (default == nil) then return nil end
    if (input == nil) then return (not ignoreDefault and default or nil) end

    local input_type = self:typeof(input)
    local output_type = self:typeof(default)

    if (input_type == output_type) then return input end

    if (output_type == 'number') then
        if (input_type == 'string') then return tonumber(input) or (not ignoreDefault and default or nil) end
        if (input_type == 'boolean') then return input and 1 or 0 end

        return (not ignoreDefault and default or nil)
    end

    if (output_type == 'string') then
        if (input_type == 'number') then return tostring(input) or (not ignoreDefault and default or nil) end
        if (input_type == 'boolean') then return input and 'yes' or 'no' end
        if (input_type == 'table') then return json.encode(input) or (not ignoreDefault and default or nil) end
        if (input_type == 'vector3') then return json.encode({ input.x, input.y, input.z }) or (not ignoreDefault and default or nil) end
        if (input_type == 'vector2') then return json.encode({ input.x, input.y }) or (not ignoreDefault and default or nil) end

        return tostring(input) or (not ignoreDefault and default or nil)
    end

    if (output_type == 'boolean') then
        if (input_type == 'string') then
            input = string.lower(input)

            if (input == 'true' or input == '1' or input == 'yes' or input == 'y') then return true end
            if (input == 'false' or input == '0' or input == 'no' or input == 'n') then return false end

            return (not ignoreDefault and default or nil)
        end

        if (input_type == 'number') then
            if (input == 1) then return true end
            if (input == 0) then return false end

            return (not ignoreDefault and default or nil)
        end

        return (not ignoreDefault and default or nil)
    end

    if (output_type == 'vector2') then
        if (input_type == 'table' or input_type == 'vector3') then
            local x = self:ensure(input.x, default.x)
            local y = self:ensure(input.y, default.y)

            return vector2(x, y)
        end

        if (input_type == 'number') then
            return vector2(input, input)
        end

        if (input_type == 'string' and self:startsWith(input, '{') and self:endsWith(input, '}')) then
            local decodedInput = self:ensure(json.decode(input), {})

            local x = self:ensure(decodedInput.x, default.x)
            local y = self:ensure(decodedInput.y, default.y)

            return vector2(x, y)
        end

        if (input_type == 'string' and self:startsWith(input, '[') and self:endsWith(input, ']')) then
            local decodedInput = self:ensure(json.decode(input), {})

            local x = self:ensure(decodedInput[1], default.x)
            local y = self:ensure(decodedInput[2], default.y)

            return vector2(x, y)
        end

        return (not ignoreDefault and default or nil)
    end

    if (output_type == 'vector3') then
        if (input_type == 'table' or input_type == 'vector2') then
            local x = self:ensure(input.x, default.x)
            local y = self:ensure(input.y, default.y)
            local z = self:ensure(input.z, input_type == 'vector2' and 0 or default.z)

            return vector3(x, y, z)
        end

        if (input_type == 'number') then
            return vector3(input, input, input)
        end

        if (input_type == 'string' and self:startsWith(input, '{') and self:endsWith(input, '}')) then
            local decodedInput = self:ensure(json.decode(input), {})

            local x = self:ensure(decodedInput.x, default.x)
            local y = self:ensure(decodedInput.y, default.y)
            local z = self:ensure(decodedInput.z, default.z)

            return vector3(x, y, z)
        end

        if (input_type == 'string' and self:startsWith(input, '[') and self:endsWith(input, ']')) then
            local decodedInput = self:ensure(json.decode(input), {})

            local x = self:ensure(decodedInput[1], default.x)
            local y = self:ensure(decodedInput[2], default.y)
            local z = self:ensure(decodedInput[3], default.z)

            return vector3(x, y, z)
        end

        return (not ignoreDefault and default or nil)
    end

    return (not ignoreDefault and default or nil)
end

function utils:switch()
    local switch = { cases = { ['default'] = function() end } }

    function switch:case(key, func)
        if (not key and not func) then return end

        if (not func and utils:typeof(key) == 'table') then
            for k, v in (key) do
                key = utils:ensure(k, 'unknown')
                func = utils:ensure(v, function() end)

                self.cases[key] = func
            end
        else
            key = utils:ensure(key, 'unknown')
            func = utils:ensure(func, function() end)

            self.cases[key] = func
        end
    end

    function switch:default(func)
        func = utils:ensure(func, function() end)

        self.cases['default'] = func
    end

    return setmetatable(switch, {
        __call = function(t, i, ...)
            i = self:ensure(i, 'unknown')

            if (t.cases[i]) then
                t.cases[i](...)
            else
                t.cases['default'](...)
            end
        end
    })
end

function utils:any(input, inputs, checkType)
    if (input == nil or inputs == nil) then return false end

    inputs = self:ensure(inputs, {})
    checkType = self:ensure(checkType, 'value')

    local checkMethod = 1

    if (checkType == 'value' or checkType == 'v') then
        checkMethod = 1
    elseif (checkType == 'key' or checkType == 'k') then
        checkMethod = -1
    elseif (checkType == 'both' or checkType == 'b') then
        checkMethod = 0
    end

    for k, v in pairs(inputs) do
        if (checkMethod == 0 or checkMethod == -1) then
            local checkK = self:ensure(input, k, true)

            if (checkK ~= nil and checkK == k) then return true end
        end

        if (checkMethod == 0 or checkMethod == 1) then
            local checkV = self:ensure(input, v, true)

            if (checkV ~= nil and checkV == v) then return true end
        end
    end

    return false
end

function utils:try(func, catch_func)
    local status, exception = pcall(func)

    if (not status) then
        catch_func(exception)
    end
end

RegisterModule(utils)