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
--Flying split or split at time selection

function SplitItemUnderMouse()
	--A
	--reaper.Main_OnCommand(40513,0) --move edit cursor to mouse cursor
	--reaper.Main_OnCommand(40528,0) --select item under mouse cursor
	--reaper.Main_OnCommand(40012,0) --split item at edit or play cursor

	--B
	reaper.Main_OnCommand(40746,0) --split item under mouse cursor
end

--proveri kolika je selekcija vremenska
start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
delta_time = end_time - start_time

if delta_time > 0 then
	selected_count = reaper.CountSelectedMediaItems(0)
	if selected_count > 0 then
		reaper.Main_OnCommand(40061,0) --split item at time selection
	else
		SplitItemUnderMouse()
	end
else
	SplitItemUnderMouse()
end
