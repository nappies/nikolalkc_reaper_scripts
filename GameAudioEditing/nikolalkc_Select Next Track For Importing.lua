--[[
 * ReaScript Name: Triple zoom out
 * Description: Pt like zoom out
  * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 * REAPER: 5.0 pre 40
]]

--[[
 * Changelog:
	* v1.1 (2017-06-13)
		+ Support for horizontal zoom center to edit cursor
	* v1.0 (2017-05-31)
		+ Initial Release
]]

reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS025564f5f1584ea3a57161e14b1362a00d4313c9"),0) --Script: nikolalkc - Move Edit Cursor To Item Start.lua
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"),0) --SWS: Select only track(s) with selected item(s)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"),0) --Xenakios/SWS: Select next tracks
reaper.Main_OnCommand(40289,0) --Track: Unselect all items
