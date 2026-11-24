scriptTitle = "Toggle xbGuard (Online / Offline)"
scriptAuthor = "Tupapa2712"
scriptVersion = 2
scriptDescription = "Enables or disables xbGuard.xex in Hdd1:\\launch.ini with automatic liveblock handling while preserving all other plugins."
scriptPermissions = { "filesystem" }

-- Path configuration (edit if your files are in a different folder or slot)
local INI_PATH    = "Hdd1:\\launch.ini"
local TARGET_SLOT = "plugin2"
local XBGUARD_VAL = "Hdd:\\Servidores\\xbGuard.xex"

-- Automatically adjusts [Settings] network flags:
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
                return true, "xbGuard ENABLED (" .. key:lower() .. ")"
            end
        end
    end
    return false, "xbGuard DISABLED (Offline / Original Xbox Mode)"
end

local function applyMode(lines, enableXbGuard, settingsMap)
    local section = ""
    local targetLineIndex = nil
    local targetCurrentVal = ""

    -- 1. Scan [Plugins]: clear any existing xbGuard.xex entry
    --    without touching any other user plugin.
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

    -- 2. If enabling xbGuard, validate the target slot
    if enableXbGuard then
        if not targetLineIndex then
            return false, "Could not find " .. TARGET_SLOT .. " under [Plugins] in " .. INI_PATH
        end
        if targetCurrentVal ~= "" then
            return false, TARGET_SLOT .. " is already occupied by another plugin:\n" .. targetCurrentVal ..
                "\n\nFree that slot or change TARGET_SLOT in Main.lua."
        end
        lines[targetLineIndex].text = TARGET_SLOT:lower() .. " = " .. XBGUARD_VAL
    end

    -- 3. Update network flags under [Settings]
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
        Script.ShowMessageBox("Error", "Could not find " .. INI_PATH, "OK")
        return
    end

    local content = FileSystem.ReadFile(INI_PATH)
    if not content or content == "" then
        Script.ShowMessageBox("Error", "Could not read " .. INI_PATH, "OK")
        return
    end

    local lines = splitLines(content)
    local _, currentStatus = detectStatus(lines)

    local promptMsg =
        "Current status:\n" .. currentStatus .. "\n\n" ..
        "Choose an option for " .. TARGET_SLOT .. " (press B to cancel):"

    local choice = Script.ShowMessageBox(
        "Toggle xbGuard",
        promptMsg,
        "Enable xbGuard",
        "Disable (Offline)"
    )

    if not choice or choice.Canceled then
        return
    end

    local enableXbGuard, settingsMap, statusMsg

    if choice.Button == 1 then
        local auroraXex = toAuroraPath(XBGUARD_VAL)
        if not FileSystem.FileExists(auroraXex) then
            Script.ShowMessageBox("File Not Found", "Could not find:\n" .. auroraXex .. "\n\nCheck XBGUARD_VAL at the top of Main.lua.", "OK")
            return
        end
        enableXbGuard = true
        settingsMap = {
            liveblock  = "false",
            livestrong = "false",
            fakelive   = "false",
            sockpatch  = "true",
        }
        statusMsg = "xbGuard ENABLED in " .. TARGET_SLOT .. " (Online / Xbox Live Mode).\n\nYour console will reboot to apply changes."
    elseif choice.Button == 2 then
        enableXbGuard = false
        settingsMap = {
            liveblock  = "true",
            livestrong = "false",
            fakelive   = "false",
        }
        statusMsg = "xbGuard DISABLED (Offline / Original Xbox Mode).\nliveblock = true (Aurora cover downloads stay active).\n\nYour console will reboot to apply changes."
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
        Script.ShowMessageBox("Error", "Could not save " .. INI_PATH, "OK")
        return
    end

    local ret = Script.ShowMessageBox("Toggle xbGuard", statusMsg, "Reboot now", "Later")
    if ret and not ret.Canceled and ret.Button == 1 then
        if Aurora.Reboot then
            Aurora.Reboot()
        else
            Aurora.Restart()
        end
    end
end
