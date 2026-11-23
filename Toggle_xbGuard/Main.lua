scriptTitle = "Selector de Servidor (xbGuard / ReLive / Offline)"
scriptAuthor = "Tupapa2712"
scriptVersion = 2
scriptDescription = "Alterna entre xbGuard, ReLive o modo Offline en Hdd1:\\launch.ini respetando tus otros plugins y reinicia la consola."
scriptPermissions = { "filesystem" }

-- Configuracion de rutas (ajusta si tus archivos estan en otra carpeta)
local INI_PATH    = "Hdd1:\\launch.ini"
local TARGET_SLOT = "plugin2"
local XBGUARD_VAL = "Hdd:\\Servidores\\xbGuard.xex"
local RELIVE_VAL  = "Hdd:\\ReLive.xex"

-- Ajusta automaticamente los parametros de red de [Settings] segun el modo:
--   xbGuard / ReLive -> liveblock=false, livestrong=false, fakelive=false, sockpatch=true
--   Offline          -> liveblock=true,  livestrong=false, fakelive=false
local MANAGE_NETWORK_SETTINGS = true

-- Plugins incompatibles que NUNCA deben coexistir en plugin1..plugin5
local INCOMPATIBLE_PLUGINS = {
    "xbguard.xex",
    "relive.xex",
    "rgloader.xex",
}

local function splitLines(text)
    local lines = {}
    local pos = 1
    while pos <= #text do
        local s, e = text:find("\r?\n", pos)
        if s then
            table.insert(lines, { text = text:sub(pos, s - 1), eol = text:sub(s, e) })
            pos = e + 1
        else
            table.insert(lines, { text = text:sub(pos), eol = "" })
            break
        end
    end
    return lines
end

local function joinLines(lines)
    local out = {}
    for i = 1, #lines do
        out[i] = lines[i].text .. lines[i].eol
    end
    return table.concat(out)
end

local function isIncompatible(val)
    local low = (val or ""):lower()
    if low == "" then return false end
    for _, name in ipairs(INCOMPATIBLE_PLUGINS) do
        if low:find(name, 1, true) then
            return true
        end
    end
    return false
end

local function toAuroraPath(dashlaunchPath)
    return (dashlaunchPath:gsub("^[hH][dD][dD]:\\", "Hdd1:\\", 1))
end

local function detectStatus(lines)
    local found = {}
    local section = ""
    for _, item in ipairs(lines) do
        local trimmed = item.text:match("^%s*(.-)%s*$")
        local sec = trimmed:match("^%[([^%]]+)%]$")
        if sec then
            section = sec:lower()
        elseif section == "plugins" and trimmed ~= "" and trimmed:sub(1, 1) ~= ";" and trimmed:sub(1, 1) ~= "#" then
            local key, val = trimmed:match("^([pP][lL][uU][gG][iI][nN][1-5])%s*=%s*(.-)%s*$")
            if key and val ~= "" then
                local low = val:lower()
                if low:find("xbguard.xex", 1, true) then
                    table.insert(found, "xbGuard (" .. key:lower() .. ")")
                elseif low:find("relive.xex", 1, true) then
                    table.insert(found, "ReLive (" .. key:lower() .. ")")
                elseif low:find("rgloader.xex", 1, true) then
                    table.insert(found, "RGLoader (" .. key:lower() .. ")")
                end
            end
        end
    end

    if #found == 0 then
        return "Modo Offline / Xbox Clasico (ningun servidor activo)"
    elseif #found == 1 then
        return found[1]
    else
        return "CONFLICTO DETECTADO: " .. table.concat(found, " + ")
    end
end

local function applyMode(lines, targetPath, settingsMap)
    local section = ""
    local targetLineIndex = nil
    local targetCurrentVal = ""

    -- 1. Escanear [Plugins]: limpiar stealth incompatibles en todos los slots
    --    sin tocar ningun otro plugin del usuario.
    for i, item in ipairs(lines) do
        local trimmed = item.text:match("^%s*(.-)%s*$")
        local sec = trimmed:match("^%[([^%]]+)%]$")
        if sec then
            section = sec:lower()
        elseif section == "plugins" and trimmed ~= "" and trimmed:sub(1, 1) ~= ";" and trimmed:sub(1, 1) ~= "#" then
            local key, val = trimmed:match("^([pP][lL][uU][gG][iI][nN][1-5])%s*=%s*(.-)%s*$")
            if key then
                local keyLower = key:lower()
                if isIncompatible(val) then
                    item.text = keyLower .. " ="
                    val = ""
                end
                if keyLower == TARGET_SLOT:lower() then
                    targetLineIndex = i
                    targetCurrentVal = val
                end
            end
        end
    end

    -- 2. Si se va a activar xbGuard o ReLive, validar el slot objetivo
    if targetPath ~= nil then
        if not targetLineIndex then
            return false, "No se encontro la linea " .. TARGET_SLOT .. " en [Plugins] de " .. INI_PATH
        end
        if targetCurrentVal ~= "" then
            return false, TARGET_SLOT .. " ya esta ocupado por otro plugin:\n" .. targetCurrentVal ..
                "\n\nLibera ese slot o cambia TARGET_SLOT en Main.lua."
        end
        lines[targetLineIndex].text = TARGET_SLOT:lower() .. " = " .. targetPath
    end

    -- 3. Ajustar parametros de red dentro de [Settings]
    if MANAGE_NETWORK_SETTINGS and settingsMap then
        section = ""
        for _, item in ipairs(lines) do
            local trimmed = item.text:match("^%s*(.-)%s*$")
            local sec = trimmed:match("^%[([^%]]+)%]$")
            if sec then
                section = sec:lower()
            elseif section == "settings" and trimmed ~= "" and trimmed:sub(1, 1) ~= ";" and trimmed:sub(1, 1) ~= "#" then
                local key = trimmed:match("^([%a_]+)%s*=")
                if key then
                    local keyLower = key:lower()
                    if settingsMap[keyLower] ~= nil then
                        item.text = keyLower .. " = " .. settingsMap[keyLower]
                    end
                end
            end
        end
    end

    return true, nil
end

function main()
    if not FileSystem.FileExists(INI_PATH) then
        Script.ShowMessageBox("Error", "No se encontro " .. INI_PATH, "OK")
        return
    end

    local content = FileSystem.ReadFile(INI_PATH)
    if not content or content == "" then
        Script.ShowMessageBox("Error", "No se pudo leer " .. INI_PATH, "OK")
        return
    end

    local lines = splitLines(content)
    local currentStatus = detectStatus(lines)

    local promptMsg =
        "Estado actual:\n" .. currentStatus .. "\n\n" ..
        "Elige el modo para " .. TARGET_SLOT .. " (presiona B para cancelar):"

    local choice = Script.ShowMessageBox(
        "Selector xbGuard / ReLive",
        promptMsg,
        "xbGuard",
        "ReLive",
        "Offline (Ninguno)"
    )

    if not choice or choice.Canceled then
        return
    end

    local targetPath, settingsMap, statusMsg

    if choice.Button == 1 then
        local auroraXex = toAuroraPath(XBGUARD_VAL)
        if not FileSystem.FileExists(auroraXex) then
            Script.ShowMessageBox("Archivo no encontrado", "No se encontro:\n" .. auroraXex .. "\n\nVerifica la ruta XBGUARD_VAL en Main.lua.", "OK")
            return
        end
        targetPath  = XBGUARD_VAL
        settingsMap = {
            liveblock  = "false",
            livestrong = "false",
            fakelive   = "false",
            sockpatch  = "true",
        }
        statusMsg   = "xbGuard ACTIVADO en " .. TARGET_SLOT .. ".\nSe limpiaron otros servidores incompatibles.\n\nReinicia la consola para aplicar el cambio."
    elseif choice.Button == 2 then
        local auroraXex = toAuroraPath(RELIVE_VAL)
        if not FileSystem.FileExists(auroraXex) then
            Script.ShowMessageBox("Archivo no encontrado", "No se encontro:\n" .. auroraXex .. "\n\nCopia ReLive.xex (junto a ReLive.ini y Themes) o ajusta RELIVE_VAL en Main.lua.", "OK")
            return
        end
        targetPath  = RELIVE_VAL
        settingsMap = {
            liveblock  = "false",
            livestrong = "false",
            fakelive   = "false",
            sockpatch  = "true",
        }
        statusMsg   = "ReLive ACTIVADO en " .. TARGET_SLOT .. ".\nUsa un perfil local/ReLive (no el de Microsoft Live).\n\nReinicia la consola para aplicar el cambio."
    elseif choice.Button == 3 then
        targetPath  = nil
        settingsMap = {
            liveblock  = "true",
            livestrong = "false",
            fakelive   = "false",
        }
        statusMsg   = "Modo OFFLINE / Xbox Clasico ACTIVADO.\nliveblock = true (caraturas de Aurora activas).\n\nReinicia la consola para aplicar el cambio."
    else
        return
    end

    local okApply, errMsg = applyMode(lines, targetPath, settingsMap)
    if not okApply then
        Script.ShowMessageBox("Error", errMsg, "OK")
        return
    end

    local newContent = joinLines(lines)
    local okWrite = FileSystem.WriteFile(INI_PATH, newContent)
    if okWrite == false then
        Script.ShowMessageBox("Error", "No se pudo guardar " .. INI_PATH, "OK")
        return
    end

    local ret = Script.ShowMessageBox("Cambio guardado", statusMsg, "Reiniciar ahora", "Luego")
    if ret and not ret.Canceled and ret.Button == 1 then
        if Aurora.Reboot then
            Aurora.Reboot()
        else
            Aurora.Restart()
        end
    end
end
