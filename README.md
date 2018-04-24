# betaflight-crsf-tx-scripts
Collection of scripts to configure Betaflight from your TX over CRSF.

### Installation
1.  Upgrade Betaflight 3.4 (build #791 or later).
2.  Copy the `crsf_cms.lua` file to the `/SCRIPTS/TELEMETRY/` directory on your Taranis.
3.  Configure your remote to load the script as a Telemetry screen.
4.  Load the Telemetry screen and the CMS data should begin streaming to your remote.

#### Can I use this with anything other than Crossfire?
While it is a technical possiblity, it is not likely.  Crossfire is currently the only system that has enough overall bandwidth to serve up this capability with adequate speed and reliability.  At this time, other platforms suffer from small frame sizes and does not transmit data rapidly enough to make this an otherwise practical solution.

#### What can I expect?
The "over-the-air" nature of these protocols are likely to suffer from occasional frame loss, so it is normal that lines may fail to appear on the screen.  If it appears that the CMS didn't load at all or that lines are missing from the display, press the "+" button to refresh the screen. This will instruct the script to request a refresh of the screen you are currently viewing. Given that this capability is in its infancy, bugs are likely to occur, so please report them as you encounter them.

#### What if I don't have a X9D?
Support for other FrSky transmitters is absolutely a 100% possibility, but is not available at this time.  We are eager to provide support for other radios, so if you are a developer wishing to improve the scripts, please feel free to fork the script.  Betaflight offers a few configuration parameters that will reduce the width and height of the interactive screen to accomodate smaller displays.

```
displayport_crsf_col_adjust = 0
Allowed range: -8 - 0

displayport_crsf_row_adjust = 0
Allowed range: -3 - 0
```

Lowering these two parameters into negative ranges will reduce the column (characters per row) and row counts. This will assist in making the screens fit better on smaller remotes.
