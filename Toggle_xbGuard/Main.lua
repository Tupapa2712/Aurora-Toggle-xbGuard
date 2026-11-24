scriptTitle = "Alternar xbGuard (Online / Offline)"
scriptAuthor = "Tupapa2712"
scriptVersion = 2
scriptDescription = "Activa o desactiva xbGuard.xex en Hdd1:\\launch.ini ajustando liveblock automaticamente y respetando tus otros plugins."
scriptPermissions = { "filesystem" }

-- Configuracion de rutas (ajusta si tus archivos estan en otra carpeta)
local INI_PATH    = "Hdd1:\\launch.ini"
local TARGET_SLOT = "plugin2"
local XBGUARD_VAL = "Hdd:\\Servidores\\xbGuard.xex"

-- Ajusta automaticamente los parametros de red de [Settings]:
--   xbGuard ON  -> liveblock=false, livestrong=false, fakelive=false, sockpatch=true
--   xbGuard OFF -> liveblock=true,  livestrong=false, fakelive=false
local MANAGE_NETWORK_SETTINGS = true

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

local function toAuroraPath(dashlaunchPath)
    return (dashlaunchPath:gsub("^[hH][dD][dD]:\\", "Hdd1:\\", 1))
end

local function isXbGuard(val)
    return (val or ""):lower():find("xbguard.xex", 1, true) ~= nil
end

local function detectStatus(lines)
    local section = ""
    for _, item in ipairs(lines) do
        local trimmed = item.text:match("^%s*(.-)%s*$")
        local sec = trimmed:match("^%[([^%]]+)%]$")
        if sec then
            section = sec:lower()
        elseif section == "plugins" and trimmed ~= "" and trimmed:sub(1, 1) ~= ";" and trimmed:sub(1, 1) ~= "#" then
            local key, val = trimmed:match("^([pP][lL][uU][gG][iI][nN][1-5])%s*=%s*(.-)%s*$")
            if key and isXbGuard(val) then
                return true, "xbGuard ACTIVADO (" .. key:lower() .. ")"
            end
        end
    end
    return false, "xbGuard DESACTIVADO (Modo Offline / Xbox Clasico)"
end

local function applyMode(lines, enableXbGuard, settingsMap)
    local section = ""
    local targetLineIndex = nil
    local targetCurrentVal = ""

    -- 1. Escanear [Plugins]: limpiar cualquier entrada previa de xbGuard.xex
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
                if isXbGuard(val) then
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

    -- 2. Si se va a activar xbGuard, validar el slot objetivo
    if enableXbGuard then
        if not targetLineIndex then
            return false, "No se encontro la linea " .. TARGET_SLOT .. " en [Plugins] de " .. INI_PATH
        end
        if targetCurrentVal ~= "" then
            return false, TARGET_SLOT .. " ya esta ocupado por otro plugin:\n" .. targetCurrentVal ..
                "\n\nLibera ese slot o cambia TARGET_SLOT en Main.lua."
        end
        lines[targetLineIndex].text = TARGET_SLOT:lower() .. " = " .. XBGUARD_VAL
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
    local _, currentStatus = detectStatus(lines)

    local promptMsg =
        "Estado actual:\n" .. currentStatus .. "\n\n" ..
        "Elige una opcion para " .. TARGET_SLOT .. " (presiona B para cancelar):"

    local choice = Script.ShowMessageBox(
        "Alternar xbGuard",
        promptMsg,
        "Activar xbGuard",
        "Desactivar (Offline)"
    )

    if not choice or choice.Canceled then
        return
    end

    local enableXbGuard, settingsMap, statusMsg

    if choice.Button == 1 then
        local auroraXex = toAuroraPath(XBGUARD_VAL)
        if not FileSystem.FileExists(auroraXex) then
            Script.ShowMessageBox("Archivo no encontrado", "No se encontro:\n" .. auroraXex .. "\n\nVerifica la ruta XBGUARD_VAL en Main.lua.", "OK")
            return
        end
        enableXbGuard = true
        settingsMap = {
            liveblock  = "false",
            livestrong = "false",
            fakelive   = "false",
            sockpatch  = "true",
        }
        statusMsg = "xbGuard ACTIVADO en " .. TARGET_SLOT .. " (Modo Online / Xbox Live).\n\nLa consola se reiniciara para aplicar el cambio."
    elseif choice.Button == 2 then
        enableXbGuard = false
        settingsMap = {
            liveblock  = "true",
            livestrong = "false",
            fakelive   = "false",
        }
        statusMsg = "xbGuard DESACTIVADO (Modo Offline / Xbox Clasico).\nliveblock = true (caratulas de Aurora activas).\n\nLa consola se reiniciara para aplicar el cambio."
    else
        return
    end

    local okApply, errMsg = applyMode(lines, enableXbGuard, settingsMap)
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

    local ret = Script.ShowMessageBox("Alternar xbGuard", statusMsg, "Reiniciar ahora", "Luego")
    if ret and not ret.Canceled and ret.Button == 1 then
        if Aurora.Reboot then
            Aurora.Reboot()
        else
            Aurora.Restart()
        end
    end
end
