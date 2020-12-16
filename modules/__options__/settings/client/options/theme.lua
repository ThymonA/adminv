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

AddThemeOption = function(settings_menu, settings, trans)
    local theme_index = 1
    local themes = {}

    for k, v in pairs(AdminV.Statics.MenuVThemes) do
        v = utils:ensure(v, 'unknown')

        if (v == settings.theme) then
            theme_index = utils:ensure(k, 1)
        end

        table.insert(themes, {
            label = trans:T(('theme_%s'):format(v)),
            value = v
        })
    end

    local theme = settings_menu:AddSlider({
        icon = '⚙️',
        label = trans:T('theme'),
        description = trans:T('theme_description'),
        value = theme_index,
        values = themes,
        saveOnUpdate = true
    })

    theme:On('select', function(item, value)
        config:SetValue('settings', 'theme', value)

        SetResourceKvp('adminv.settings.theme', value)

        for k, v in pairs(MenuV.Menus or {}) do
            if (utils:typeof(v) == 'Menu') then
                if (value == 'default') then
                    v.Color = {
                        R = (settings.color or {}).r or 255,
                        G = (settings.color or {}).g or 0,
                        B = (settings.color or {}).b or 0
                    }
                else
                    v.Color = { R = 255, G = 255, B = 255 }
                end

                v.Theme = value
            end
        end

        MenuV:Refresh()
    end)
end