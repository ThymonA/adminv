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

config.position = utils:ensure(GetResourceKvpString('adminv.settings.position'), 'topleft')
config.size = utils:ensure(GetResourceKvpString('adminv.settings.size'), 'size-125')
config.color = {
    r = 255,
    g = 0,
    b = 0
}
config.theme = utils:ensure(GetResourceKvpString('adminv.settings.theme'), 'native')

--- Validate settings
if (not utils:any(config.position, AdminV.Statics.MenuVPositions, 'value')) then config.position = 'topleft' end
if (not utils:any(config.size, AdminV.Statics.MenuVSizes, 'value')) then config.size = 'size-125' end
if (not utils:any(config.theme, AdminV.Statics.MenuVThemes, 'value')) then config.theme = 'native' end