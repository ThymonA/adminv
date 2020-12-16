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

local stored_translations = {}
local translations = { __class = 'translations' }

M('config')

local function load_translation(name)
    name = type(name) == 'string' and name or NAME or 'unknown'
    name = string.lower(name)

    if (name == 'unknown') then return {} end
    if (stored_translations == nil) then stored_translations = {} end
    if (stored_translations[name] ~= nil) then
        return stored_translations[name]
    end

    local language = config('core').language or 'en'
    local fallback_lang = config().fallback_language or 'en'

    language = type(language) == 'string' and language or 'en'
    fallback_lang = type(fallback_lang) == 'string' and fallback_lang or 'en'

    local modules = GetModules()

    for k, v in pairs(modules) do
        local m_name = type(v.name) == 'string' and v.name or 'unknown'
        local m_dir = type(v.directory) == 'string' and v.directory or 'unknown'

        if (string.lower(m_name) == name) then
            local m_translations = {}
            local m_trans_dir, m_trans_raw, m_trans_data = nil, nil, nil

            if (language ~= fallback_lang) then
                m_trans_dir = ('%s/translations/%s.json'):format(m_dir, fallback_lang)
                m_trans_raw = LoadResourceFile(RESOURCE, m_trans_dir)

                if (m_trans_raw) then
                    m_trans_data = json.decode(m_trans_raw)

                    if (m_trans_data) then
                        m_trans_data = type(m_trans_data) == 'table' and m_trans_data or {}

                        for tk, tv in pairs(m_trans_data) do
                            tk = type(tk) == 'string' and tk or tostring(tk) or 'unknown'
                            tv = type(tv) == 'string' and tv or tostring(tv) or 'unknown'

                            m_translations[tk] = tv
                        end
                    end
                end
            end

            m_trans_dir = ('%s/translations/%s.json'):format(m_dir, language)
            m_trans_raw = LoadResourceFile(RESOURCE, m_trans_dir)

            if (m_trans_raw) then
                m_trans_data = json.decode(m_trans_raw)

                if (m_trans_data) then
                    m_trans_data = type(m_trans_data) == 'table' and m_trans_data or {}

                    for tk, tv in pairs(m_trans_data) do
                        tk = type(tk) == 'string' and tk or tostring(tk) or 'unknown'
                        tv = type(tv) == 'string' and tv or tostring(tv) or 'unknown'

                        m_translations[tk] = tv
                    end
                end
            end

            stored_translations[string.lower(m_name)] = m_translations

            return m_translations
        end
    end

    return {}
end

function translations:LoadTranslations(name)
    name = type(name) == 'string' and name or GetInvokingModule() or _PARENT.NAME or NAME or 'unknown'

    return load_translation(name)
end

--- Register translations as module
RegisterModule(setmetatable(translations, {
    __index = function(t, k)
        k = type(k) == 'string' and k or tostring(k) or 'unknown'

        return translations:LoadTranslations(k)
    end,
    __newindex = function(t, k, v)
        error('cannot set values on translations')
    end,
    __call = function(t, k)
        k = type(k) == 'string' and k or GetInvokingModule() or 'unknown'

        return setmetatable({
            __class = 'module_translations',
            data = translations:LoadTranslations(k),
            T = function(t, k, ...)
                if (type(t) ~= 'table') then
                    error('invalid function usage change <translation>.T(k, ...) to <translation>:T(k, ...)')
                    return
                end

                k = type(k) == 'string' and k or type(k) ~= 'nil' and tostring(k) or 'unknown'

                local raw_trans = rawget(t.data, k)

                if (raw_trans == nil or k == 'unknown') then return 'MISSING TRANSLATION' end

                raw_trans = type(raw_trans) == 'string' and raw_trans or 'MISSING TRANSLATION'

                return raw_trans:format(...)
            end
        }, {
            __index = function(t, k)
                k = type(k) == 'string' and k or tostring(k) or 'unknown'

                return rawget(t.data, k)
            end,
            __newindex = function(t, k, v)
                error('cannot set values on translations')
            end,
            __pairs = function(t)
                return pairs(t.data)
            end
        })
    end,
    __pairs = function(t)
        return pairs(translations:LoadTranslations())
    end
}))