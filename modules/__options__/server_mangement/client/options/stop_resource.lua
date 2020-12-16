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

local enabled = false
local trans = nil
local stop_resource_menu = nil
local running_resources = {}

local stop_resource = function(item)
    local resource = utils:ensure(item.Value, 'unknown')

    if (((AdminV.Permissions or {}).ServerManagement or {}).StopResource) then
        TriggerServerEvent('adminv:server_mangement:stopResource', resource)
    end
end

local refresh = function()
    stop_resource_menu:ClearItems()

    table.sort(running_resources)

    for k, v in pairs(running_resources) do
        stop_resource_menu:AddButton({
            label = v,
            value = v,
            description = trans:T('resource_stop_description', v),
            select = stop_resource
        })
    end

    if (#running_resources <= 0) then
        stop_resource_menu:AddButton({
            label = trans:T('no_stop_description'),
            select = function(item)
                local parent = item:GetParentMenu()

                if (parent) then
                    parent:Close()
                end
            end
        })
    end
end

AddGlobalEventHandler('onResourceStop', function(name)
    if (not enabled) then return end

    name = utils:ensure(name, 'unknown')

    if (utils:any(string.lower(name), { '_cfx_internal', 'adminv', 'menuv' }, 'value')) then
        return
    end

    for k, v in pairs(running_resources) do
        v = utils:ensure(v, 'unknown')

        if (name == v) then
            table.remove(running_resources, k)
        end
    end

    refresh()
end)

AddGlobalEventHandler('onResourceStart', function(name)
    if (not enabled) then return end

    name = utils:ensure(name, 'unknown')

    if (utils:any(string.lower(name), { '_cfx_internal', 'adminv', 'menuv' }, 'value')) then
        return
    end

    local exits = utils:any(name, running_resources, 'value')

    if (not exits) then
        table.insert(running_resources, name)
    end

    refresh()
end)

AddStopResourceOption = function(server_management_menu, _trans)
    enabled = true
    trans = _trans

    stop_resource_menu = server_management_menu:InheritMenu({
        title = trans:T('stop_resource'),
        subtitle = ('%s > %s'):format(trans:T('server_management'), trans:T('stop_resource'))
    })

    server_management_menu:AddButton({
        icon = '🛑',
        label = trans:T('stop_resource'),
        description = trans:T('stop_resource_description'),
        value = stop_resource_menu
    })

    local numberOfResource = GetNumResources()

    for i = 0, numberOfResource, 1 do
        local resourceName = utils:ensure(GetResourceByFindIndex(i), 'unknown')
        local resourceState = GetResourceState(resourceName)

        if (resourceState == 'started' and not utils:any(string.lower(resourceName), { '_cfx_internal', 'adminv', 'menuv' }, 'value')) then
            table.insert(running_resources, resourceName)
        end
    end

    refresh()
end