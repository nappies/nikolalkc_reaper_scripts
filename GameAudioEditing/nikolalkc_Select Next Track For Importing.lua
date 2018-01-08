--[[
  ReaScript Name: Select Next Track For Importing
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5.0 pre 40
  Version: 1.1
  About:
    Assign this script to a key in MediaExporer Section of ActionList. After running this script. Edit cursor goes back to start of selected item.
    After that next track is selected. This allows you to double click on item in media exploerer and it will be imported one track under last selected item,
    rather than selected item's track.
    NOTE: Depends on Script: nikolalkc - Move Edit Cursor To Item Start.lua, change your ID if it doesn't work.
]]

--[[
 * Changelog:
	* v1.1 (2017-06-13)
		+ Support for horizontal zoom center to edit cursor
	* v1.0 (2017-05-31)
		+ Initial Release
]]

reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSf080f92f0637edd8f4e868bb8afba37f4102e3b1"),0) --Script: nikolalkc - Move Edit Cursor To Item Start.lua
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"),0) --SWS: Select only track(s) with selected item(s)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"),0) --Xenakios/SWS: Select next tracks
reaper.Main_OnCommand(40289,0) --Track: Unselect all items
