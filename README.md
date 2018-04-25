# betaflight-crsf-tx-scripts
Collection of scripts to configure Betaflight from your TX over CRSF.

### Supported Radios
- FrSky Taranis QX7, QX7S, X9D, X9D+

### Installation
1.  Upgrade to Betaflight 3.4 (build #792 or later).
2.  **If you are using a X7 series transmitter, enter `set displayport_crsf_col_adjust = -6` in cli and save before continuing.**
2.  Copy the `crsfdp.lua` file to the `/SCRIPTS/TELEMETRY/` directory on your Taranis.
3.  Configure your remote to load the script as a Telemetry screen.  Running the script manually from the SD card is not supported and will not work properly
4.  Load the telemetry screen and the CMS menus should begin streaming to your remote.

### Instructions
Once you have configured this script as a telemetry screen, you can invoke it by holding the page button.  The script will request the menu from the FC causing data to begin streaming to your transmitter.  **Use the sticks to navigate the menus, not the buttons or jog wheel!**  This script operates in the same way as the CMS menus on the OSD, so the same stick commands apply.  If at any point a line or cursor fails to appear, press the refresh button to reload the current screen.  On the X9D, a refresh can be triggered by pressing the [+] button.  If you are using an X7, press the [ENTER] button in the center of the jog wheel.  You can exit the menus by either navigating to the main menu and use one of the exit options.  Otherwise, you can hold the [EXIT] button and the script will close the menu for you.

#### Can I use this with anything other than Crossfire?
While it is a technical possibility, it is not likely.  Crossfire is currently the only system that has enough overall bandwidth to serve up this capability with adequate speed and reliability.  At this time, other platforms suffer from small frame sizes and do not transmit data rapidly enough to make this an otherwise practical solution.

#### What can I expect?
The "over-the-air" nature of these protocols are likely to suffer from occasional frame loss, so it is normal that lines may fail to appear on the screen.  If it appears that the CMS didn't load at all or that lines are missing from the display, press the "+" button to refresh the screen. This will instruct the script to request a refresh of the screen you are currently viewing. Given that this capability is in its infancy, bugs are likely to occur so please report them if they are encountered.

#### What if I don't have a X9 or X7?
Support for other FrSky transmitters is absolutely a possibility, but is not available at this time.  We are eager to provide support for other radios, so if you are a developer wishing to improve the scripts, please feel free to fork and submit a pull request.  Betaflight offers a few configuration parameters that will reduce the width and height of the interactive screen to accomodate smaller displays.

```
displayport_crsf_col_adjust = 0
Allowed range: -8 - 0

displayport_crsf_row_adjust = 0
Allowed range: -3 - 0
```

Lowering these two parameters into negative ranges will reduce the column (characters per row) and row counts. This will assist in making the screens fit better on smaller remotes.
