--[[
 * ReaScript Name:
 * Description:
 * Instructions:
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 * REAPER: 5+
 * Extensions: SWS
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (201x-xx-xx)
	+ Initial Release
--]]
--for flying cursor (no need for clicking)
reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
reaper.Main_OnCommand(40528,0) --Item: Select item under mouse cursor

reaper.Main_OnCommand(40510,0)--Item: Fade items out from cursor
