# Aurora Stealth Server Switcher (xbGuard / ReLive / Offline)

If you use **xbGuard** or **ReLive** on your RGH Xbox 360—or switch to **Offline / Original Xbox** mode to avoid stealth-server compatibility issues with Original Xbox titles—editing `launch.ini` in Dashlaunch every single time gets tedious fast.

This ready-to-use **Aurora Dashboard Utility Script** lets you switch cleanly between **xbGuard**, **ReLive**, or **Offline Mode (both disabled)** right from Aurora and reboot immediately to apply changes.

## Key Features
- **3-Way Switcher in One Menu:** Choose between **xbGuard**, **ReLive**, or **Offline (None)** directly from Aurora (press **B** to cancel).
- **Strict Mutual Exclusion (`plugin1`–`plugin5`):** Automatically scans all 5 Dashlaunch plugin slots and clears `xbGuard.xex`, `ReLive.xex`, or `RGLoader.xex` before activating the selected server so incompatible environments never boot together.
- **Preserves Your Other Plugins:** Never modifies or removes unrelated plugins (such as `xbdm.xex`, `JRPC2.xex`, `UsbdSecPatch.xex`, `t240.xex`, etc.) or commented lines in `launch.ini`.
- **Slot Safety & File Check:** Refuses to overwrite `plugin2` if another unrelated plugin occupies it, and verifies that the selected `.xex` exists on HDD before saving.
- **Automatic `liveblock` Handling (Optional):** Sets `liveblock = false` when enabling xbGuard/ReLive and `liveblock = true` in Offline mode (keeping `livestrong = false` so Aurora cover downloads keep working). Can be toggled via `MANAGE_LIVEBLOCK` in `Main.lua`.

## Prerequisites
By default, the script uses the `plugin2` slot and the following paths:
- **xbGuard:** `Hdd:\Servidores\xbGuard.xex`
- **ReLive:** `Hdd:\ReLive.xex` *(along with `ReLive.ini` and the `Themes\` folder on `Hdd:\`)*

If your `.xex` paths or target slot are different, simply edit `TARGET_SLOT`, `XBGUARD_VAL`, or `RELIVE_VAL` at the top of `Main.lua`.

## Installation Instructions
1. Download and extract the `Toggle_xbGuard` folder (containing `Main.lua`) from [**Releases**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/releases/latest).
2. Copy the folder via FTP or Aurora's File Manager to:
   `Hdd1:\Aurora\User\Scripts\Utility\`
   *(Note: If your Aurora folder has a different name—for example `AuroraLaunch`—replace `Aurora` with your actual folder name).*
3. Run the script:
   - Inside Aurora, press the **Back** button on your controller.
   - Go to **Scripts** → **Selector de Servidor (xbGuard / ReLive / Offline)**.
   - Pick **xbGuard**, **ReLive**, or **Offline (Ninguno)**, then choose **Reiniciar ahora**.

## Issues & Troubleshooting
- **Could not find/read `Hdd1:\launch.ini`:** Make sure `launch.ini` is located at the root of your internal HDD (`Hdd1:\launch.ini`) and that `Main.lua` keeps `scriptPermissions = { "filesystem" }`.
- **File not found error:** Confirm that `xbGuard.xex` / `ReLive.xex` matches the path configured at the top of `Main.lua`.
- **Target slot already occupied:** Free `plugin2` in Dashlaunch or change `TARGET_SLOT` in `Main.lua` to an empty slot.
- **Found a bug or need help?** Open an issue in the [**Issues**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/issues) tab with your Aurora version and `[Plugins]` section from `launch.ini`.

*(Note: This script and guide were created with the assistance of Google's Gemini AI).*
