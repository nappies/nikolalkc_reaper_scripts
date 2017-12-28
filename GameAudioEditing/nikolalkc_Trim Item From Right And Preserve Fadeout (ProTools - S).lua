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
--Trim item from right side and preserve fadeout

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


function Main()
	--for flying cursor (no need for clicking)
	reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
	reaper.Main_OnCommand(40528,0) --Item: Select item under mouse cursor

	selected_item = reaper.GetSelectedMediaItem(0,0)
	if selected_item == nil then
		--Msg("PRAZNO")
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
		--ako si na fadeout delu
		if fadeout_len > cursor_end_delta then
			new_fadeout_time = fadeout_len - cursor_end_delta
			reaper.SetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN",new_fadeout_time)
			reaper.Main_OnCommand(41310, 0) --Trim right edge of item to edit cursor
		else
			--ako si na fadein delu
			if fadein_len > cursor_delta then
				reaper.Main_OnCommand(40509, 0) --fadein item to cursor
			--ako si na sredini klipa
			else
				reaper.SetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN",0)
				reaper.Main_OnCommand(41310, 0) --Trim right edge of item to edit cursor
			end

		end


	end



	reaper.UpdateArrange()
end
Main()
