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

AddPositionOption = function(settings_menu, settings, trans)
    local pos_index = 1
    local positions = {}

    for k, v in pairs(AdminV.Statics.MenuVPositions) do
        v = utils:ensure(v, 'unknown')

        if (v == settings.position) then
            pos_index = utils:ensure(k, 1)
        end

        table.insert(positions, {
            label = trans:T(('position_%s'):format(v)),
            value = v
        })
    end

    local position = settings_menu:AddSlider({
        icon = '⚙️',
        label = trans:T('position'),
        description = trans:T('position_description'),
        value = pos_index,
        values = positions,
        saveOnUpdate = true
    })

    position:On('select', function(item, value)
        config:SetValue('settings', 'position', value)

        SetResourceKvp('adminv.settings.position', value)

        for k, v in pairs(MenuV.Menus or {}) do
            if (utils:typeof(v) == 'Menu') then
                v.Position = value
            end
        end

        MenuV:Refresh()
    end)
end