# Aurora Toggle xbGuard

If you play Original Xbox games on your RGH Xbox 360 and use **xbGuard**, disabling it in DashLaunch every single time gets tedious fast—especially because **xbGuard has compatibility issues with Original Xbox games**.

This ready-to-use **Aurora Dashboard Utility Script** lets you toggle `xbGuard.xex` **ON** or **OFF (Offline)** in your `Hdd1:\launch.ini` (`plugin2` slot), automatically adjusts `liveblock` in `[Settings]`, preserves all your other plugins, and prompts you to reboot right from Aurora.

## Key Features
- **Simple 2-Mode Toggle:** Choose **Activar xbGuard** (Online / Xbox Live) or **Desactivar (Offline)** directly from Aurora (press **B** to cancel).
- **Automatic `liveblock` Protection:**
  | Mode | `plugin2` | `liveblock` | `livestrong` | `fakelive` | `sockpatch` |
  |---|---|---|---|---|---|
  | **xbGuard ON (Online)** | `Hdd:\Servidores\xbGuard.xex` | `false` | `false` | `false` | `true` |
  | **xbGuard OFF (Offline)** | *(empty)* | `true` | `false` | `false` | *(unchanged)* |
  *(Keeping `livestrong = false` in Offline mode blocks Xbox Live traffic while letting Aurora continue downloading cover art and homebrew updates).*
- **Preserves All Other Plugins:** Safely edits only `[Plugins]` / `[Settings]` line-by-line (ignoring comments) without touching `plugin1`, `plugin3`, `plugin4`, or `plugin5`.
- **Slot Safety & File Check:** Verifies that `xbGuard.xex` exists on HDD and refuses to overwrite `plugin2` if another unrelated plugin is already using it.

## Prerequisites
By default, this script expects `xbGuard.xex` at `Hdd:\Servidores\xbGuard.xex` and manages the `plugin2` slot. If your path or slot is different, edit `TARGET_SLOT` or `XBGUARD_VAL` at the top of `Main.lua`.

## Installation Instructions
1. Download and extract the `Toggle_xbGuard` folder (containing `Main.lua`) from [**Releases**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/releases/latest).
2. Copy the folder via FTP or Aurora's File Manager to:
   `Hdd1:\Aurora\User\Scripts\Utility\`
3. Run the script:
   - Inside Aurora, press the **Back** button on your controller.
   - Go to **Scripts** → **Alternar xbGuard (Online / Offline)**.
   - Choose **Activar xbGuard** or **Desactivar (Offline)**, then select **Reiniciar ahora**.

## Issues & Troubleshooting
- **Could not find/read `Hdd1:\launch.ini`:** Make sure `launch.ini` is in the root of your internal HDD (`Hdd1:\launch.ini`) and that `Main.lua` keeps `scriptPermissions = { "filesystem" }`.
- **File not found error:** Confirm that `xbGuard.xex` exists at the path configured in `XBGUARD_VAL`.
- **Target slot already occupied:** Free `plugin2` in DashLaunch or change `TARGET_SLOT` in `Main.lua` to an empty slot.
- **Found a bug or need help?** Open an issue in the [**Issues**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/issues) tab with your Aurora version and `[Plugins]` section from `launch.ini`.

*(Note: This script and guide were created with the assistance of Google's Gemini AI).*
