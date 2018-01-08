--[[
  ReaScript Name:Trim item from left and preserve fadein
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
  About:
    Cuts left part of item where mouse cursor is positioned and shortens lenth of fadein, like Pro Tools
    Instructions: Hover your mouse over item and run the script
]]

--[[
 * Changelog:
 * v1.0 (201x-12-28)
	+ Initial Release
--]]
--Trim item from left side and preserve fadein

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


function Main()
	--for flying cursor (no need for clicking)
	reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
	reaper.Main_OnCommand(40528,0) --Item: Select item under mouse cursor


	selected_item = reaper.GetSelectedMediaItem(0,0)
	if selected_item == nil then
		--Msg("Nothing selected")
	else
		--get stuff
		item_pos = reaper.GetMediaItemInfo_Value(selected_item,"D_POSITION")
		fadein_len = reaper.GetMediaItemInfo_Value(selected_item,"D_FADEINLEN")
		fadeout_len = reaper.GetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN")
		item_len = reaper.GetMediaItemInfo_Value(selected_item,"D_LENGTH")
		cursor_pos =  reaper.GetCursorPosition()

		--calculate stuff
		item_end = item_pos + item_len
		cursor_delta = cursor_pos - item_pos
		cursor_end_delta = item_end - cursor_pos

		--do stuff
		--mouse cursor at fadein part
		if fadein_len > cursor_delta then
			new_fadein_time = fadein_len - cursor_delta
			reaper.SetMediaItemInfo_Value(selected_item,"D_FADEINLEN",new_fadein_time)
			reaper.Main_OnCommand(41305, 0) --Trim left edge of item to edit cursor
		else
			--mouse cursor at fadeout part
			if fadeout_len > cursor_end_delta then
				reaper.Main_OnCommand(40510, 0) --Item: Fade items out from cursor

			else --mouse cursor at middle of item
				reaper.SetMediaItemInfo_Value(selected_item,"D_FADEINLEN",0)
				reaper.Main_OnCommand(41305, 0) --Trim left edge of item to edit cursor
			end
		end


	end



	reaper.UpdateArrange()
end
Main()
