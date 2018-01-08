--[[
  ReaScript Name:wGroup -  Select Next Wrap Group
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
  About:
    Goes to first next wGroup in timeline and selects it
    Instructions: Bind it to shortcut RIGHT and just press button (NOTE: It still needs improvements)
]]

--[[
 * Changelog:
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

prev_group_id = nil
last_item = ""
--MAIN FUNCTION
function Main()

	reaper.Main_OnCommand(40296,0) --select all tracks
	selected_count = reaper.CountSelectedMediaItems(0)

	if selected_count > 0 then
		FindNext()
	else
		reaper.Main_OnCommand(40417,0) -- select and move to next item
		--reaper.Main_OnCommand(40416,0) -- select and move to prev item
		SelectFirst()
	end



	--cursor_pos =  reaper.GetCursorPosition() --get cursor position
	--Msg(cursor_pos)
	--reaper.Main_OnCommand(40318,0) --move cursor left to edge item
	--reaper.Main_OnCommand(41589,0) --show media item properties
end


function FindNext()
	item = reaper.GetSelectedMediaItem(0,0)
	cur_group_id = reaper.GetMediaItemInfo_Value(item,"I_GROUPID")
	prev_group_id = cur_group_id


	while (cur_group_id == prev_group_id or cur_group_id == 0) and (prev_item ~= item)  do
		prev_item = item
		prev_group_id = cur_group_id

		reaper.Main_OnCommand(40417,0) -- select and move to next item
		--reaper.Main_OnCommand(40416,0) -- select and move to prev item
		item = reaper.GetSelectedMediaItem(0,0)
		cur_group_id = reaper.GetMediaItemInfo_Value(item,"I_GROUPID")

	end

	SelectFirst()
	CheckItemPos()
	--Msg("It's not same")
end

function SelectFirst()
		reaper.Main_OnCommand(40034,0) -- select all items in group
		sel_item = reaper.GetSelectedMediaItem(0,0)
		reaper.Main_OnCommand(40289,0) --unselect all items
		reaper.SetMediaItemSelected(sel_item,true)
end

last_item_pos = 0
function CheckItemPos()
	item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION")

	if last_item_pos == item_pos then
		last_item_pos = item_pos
		FindNext()
	end

end

--RUN
reaper.PreventUIRefresh( 1 )
Main()
reaper.PreventUIRefresh( -1 )
reaper.UpdateArrange()
