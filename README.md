# Aurora Toggle xbGuard

If you play Original Xbox games on your RGH Xbox 360 and use **xbGuard**, disabling it in Dashlaunch every single time gets tedious fast—especially because **xbGuard has serious compatibility issues with Original Xbox games**. Here is a ready-to-use Aurora Utility Script that toggles `xbGuard.xex` ON/OFF in your `launch.ini` (`plugin2` slot) and prompts you to reboot right from the dashboard, so you can easily disable it for Original Xbox titles and re-enable it for online play and achievements.

## Prerequisites
This script assumes `xbGuard.xex` is set in the `plugin2` slot at `Hdd:\Servidores\xbGuard.xex`. (If your path or plugin slot is different, simply edit those two lines at the top of `Main.lua`).

## Installation Instructions
1. Download and extract the `Toggle_xbGuard` folder (which contains the `Main.lua` file) from [**Releases**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/releases/latest).
2. Copy the folder via FTP or using Aurora's File Manager to:
   `Hdd1:\Aurora\User\Scripts\Utility\`
   *(Note: If your Aurora folder has a different name, replace `Aurora` with your actual folder name).*
3. Run the script:
   - Inside Aurora, press the **Back** button on your controller.
   - Go to **Scripts**, select **Alternar xbGuard (Online / Xbox Clasico)**, and choose **Reboot now**.

## Issues & Troubleshooting
- **Could not find/read `Hdd1:\launch.ini`:** Make sure `launch.ini` is in the root of your internal HDD (`Hdd1:\launch.ini`) and that `Main.lua` keeps `scriptPermissions = { "filesystem" }`.
- **Found a bug or need help?** Open an issue in the [**Issues**](https://github.com/Tupapa2712/Aurora-Toggle-xbGuard/issues) tab with your Aurora version and `launch.ini` plugin slot details.

*(Note: This script and guide were created with the assistance of Google's Gemini AI).*
