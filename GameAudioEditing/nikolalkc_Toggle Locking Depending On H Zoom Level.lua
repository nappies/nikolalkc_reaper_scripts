--[[
 * ReaScript Name: SNF = Toggle Locking depending on h zoom level
 * Description: if zoom level is less than 90, locking is enabled, else is disabled
 * Instructions: Run script afrer zooming, enable parameters for locking: item edges, item fade/volume handles, item stretch markers, item envelopes, track envelopes
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 * File URL:
 * REAPER: 5.0 pre 40
 * Extensions:
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-04-26)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--MEAT================================================================================================

--MAIN FUNCTION
function Main()
	zoom_level =  reaper.GetHZoomLevel()
	--Msg(zoom_level)
	if zoom_level < 20 then
		reaper.Main_OnCommand(40569,0) --enable locking
	else
		reaper.Main_OnCommand(40570,0) --disable locking
	end
end
--RUN
Main()
