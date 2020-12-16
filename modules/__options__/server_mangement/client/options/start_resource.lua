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
local start_resource_menu = nil
local stopped_resources = {}

local start_resource = function(item)
    local resource = utils:ensure(item.Value, 'unknown')

    if (((AdminV.Permissions or {}).ServerManagement or {}).StartResource) then
        TriggerServerEvent('adminv:server_mangement:startResource', resource)
    end
end

local refresh = function()
    start_resource_menu:ClearItems()

    table.sort(stopped_resources)

    for k, v in pairs(stopped_resources) do
        start_resource_menu:AddButton({
            label = v,
            value = v,
            description = trans:T('resource_start_description', v),
            select = start_resource
        })
    end

    if (#stopped_resources <= 0) then
        start_resource_menu:AddButton({
            label = trans:T('no_start_description'),
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

    local exits = utils:any(name, stopped_resources, 'value')

    if (not exits) then
        table.insert(stopped_resources, name)
    end

    refresh()
end)

AddGlobalEventHandler('onResourceStart', function(name)
    if (not enabled) then return end

    name = utils:ensure(name, 'unknown')

    if (utils:any(string.lower(name), { '_cfx_internal', 'adminv', 'menuv' }, 'value')) then
        return
    end

    for k, v in pairs(stopped_resources) do
        v = utils:ensure(v, 'unknown')

        if (name == v) then
            table.remove(stopped_resources, k)
        end
    end

    refresh()
end)

AddStartResourceOption = function(server_management_menu, _trans)
    enabled = true
    trans = _trans

    start_resource_menu = server_management_menu:InheritMenu({
        title = trans:T('start_resource'),
        subtitle = ('%s > %s'):format(trans:T('server_management'), trans:T('start_resource'))
    })

    server_management_menu:AddButton({
        icon = '✅',
        label = trans:T('start_resource'),
        description = trans:T('start_resource_description'),
        value = start_resource_menu
    })

    local numberOfResource = GetNumResources()

    for i = 0, numberOfResource, 1 do
        local resourceName = utils:ensure(GetResourceByFindIndex(i), 'unknown')
        local resourceState = GetResourceState(resourceName)

        if (resourceState == 'stopped' and not utils:any(string.lower(resourceName), { '_cfx_internal', 'adminv', 'menuv' }, 'value')) then
            table.insert(stopped_resources, resourceName)
        end
    end

    refresh()
end