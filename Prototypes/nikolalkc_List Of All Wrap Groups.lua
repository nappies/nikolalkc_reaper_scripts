--[[
 * ReaScript Name: SNF - Rename next clip group
 * Description: Goes to first next vertical or horizontal snf clip group and opens item properties for first empty midi item
 * Instructions: Bind it to shortcut RIGHT and just press button
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/AutoHotKey_Macros/tree/master/Reaper%20Scripts
 * REAPER: 5.0 pre 40
 * Extensions: SWS
 * Version: 1.0
]]
 
--[[
 * Changelog:
 * v1.1 (2017-05-29)
	+ Rewritten completely
 * v1.0 (2017-04-05)
	+ First Version
]]

--[[ ----- DEBUGGING ===>
	--reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"),0) --select items under edit cursor on selected tracks
]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end
group_id = {}
group_item = {}
title_item = {}
title_item_start_pos = {}
idx = 0
--MAIN FUNCTION
function Main()
	reaper.Main_OnCommand(40182,0) --select all items
	selected_count = reaper.CountSelectedMediaItems(0)
	
	
	--create array of all grouped items
	for i = 0, selected_count-1 do												
		local item = reaper.GetSelectedMediaItem(0,i)
		local cur_group_id = reaper.GetMediaItemInfo_Value(item,"I_GROUPID")
		if cur_group_id ~= 0.0 then
			group_item[idx] = item
			group_id[idx] = cur_group_id
			idx = idx + 1
		end
	end
	

	--create array of all title items
	for i = 0, idx-1 do 
		reaper.Main_OnCommand(40289,0) --unselect all items	
		reaper.SetMediaItemSelected( group_item[i], true)
		reaper.Main_OnCommand(40034,0) --select all items in group
		CheckIfAlreadyFound(group_item[i])
		if found == false  then
			FindFirstInGroup()
		end
	end
	
end

processed_group = {}
ProcIdx = 0
function CheckIfAlreadyFound(item) 
	local cur_group_id = reaper.GetMediaItemInfo_Value(item,"I_GROUPID")
	found = false
	for i = 0, ProcIdx-1 do
		if cur_group_id == processed_group[i] then
			found = true
			break
		end
	end
	
	if found == false then
		processed_group[ProcIdx] = cur_group_id
		ProcIdx = ProcIdx +1
	end
end

function FindFirstInGroup()
	first_in_group = nil
	sel_count = reaper.CountSelectedMediaItems(0)
	
	last_num = nil
	for i = 0, sel_count-1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		track =  reaper.GetMediaItem_Track( item )
		num = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
		
		if last_num == nil then
			smallest_track_item = item
		else 
			if num < last_num then
				smallest_track_item = item
			end
		end
		
		last_num = num
	end
	
		--get stuff from item
	
	take = reaper.GetMediaItemTake(smallest_track_item, 0)
	name =  reaper.GetTakeName(take)
	Msg(name)
end

--RUN
reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
