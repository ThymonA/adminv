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

AddSizeOption = function(settings_menu, settings, trans)
    local size_index = 1
    local sizes = {}

    for k, v in pairs(AdminV.Statics.MenuVSizes) do
        v = utils:ensure(v, 'unknown')

        if (v == settings.size) then
            size_index = utils:ensure(k, 1)
        end

        table.insert(sizes, {
            label = v:sub(6),
            value = v
        })
    end

    local size = settings_menu:AddSlider({
        icon = '⚙️',
        label = trans:T('size'),
        description = trans:T('size_description'),
        value = size_index,
        values = sizes,
        saveOnUpdate = true
    })

    size:On('select', function(item, value)
        config:SetValue('settings', 'size', value)

        SetResourceKvp('adminv.settings.size', value)

        for k, v in pairs(MenuV.Menus or {}) do
            if (utils:typeof(v) == 'Menu') then
                v.Size = value
            end
        end

        MenuV:Refresh()
    end)
end