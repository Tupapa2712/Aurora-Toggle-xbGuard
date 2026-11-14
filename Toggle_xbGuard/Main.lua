scriptTitle = "Alternar xbGuard (Online / Xbox Clasico)"
scriptAuthor = "Community"
scriptVersion = 1
scriptDescription = "Activa o desactiva xbGuard.xex en Hdd1:\\launch.ini y reinicia la consola automaticamente."
scriptPermissions = { "filesystem" }

local INI_PATH = "Hdd1:\\launch.ini"
local XBGUARD_VAL = "Hdd:\\Servidores\\xbGuard.xex"

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

    local is_enabled = content:lower():find("plugin2%s*=%s*hdd:\\servidores\\xbguard%.xex") ~= nil
    local new_content, n, status_msg

    if is_enabled then
        new_content, n = content:gsub("([pP][lL][uU][gG][iI][nN]2%s*=)[^\r\n]*", "%1", 1)
        status_msg = "xbGuard DESACTIVADO (Modo para utilizar Xbox Clasico).\n\nLa consola se reiniciara para aplicar el cambio."
    else
        new_content, n = content:gsub("([pP][lL][uU][gG][iI][nN]2%s*=)[^\r\n]*", "%1 " .. XBGUARD_VAL, 1)
        status_msg = "xbGuard ACTIVADO (Modo Online / Logros).\n\nLa consola se reiniciara para aplicar el cambio."
    end

    if n == 0 then
        Script.ShowMessageBox("Error", "No se encontro la linea plugin2 en " .. INI_PATH, "OK")
        return
    end

    local ok = FileSystem.WriteFile(INI_PATH, new_content)
    if ok == false then
        Script.ShowMessageBox("Error", "No se pudo guardar " .. INI_PATH, "OK")
        return
    end

    local ret = Script.ShowMessageBox("Alternar xbGuard", status_msg, "Reiniciar ahora", "Luego")
    if ret and not ret.Canceled and ret.Button == 1 then
        if Aurora.Reboot then
            Aurora.Reboot()
        else
            Aurora.Restart()
        end
    end
end
