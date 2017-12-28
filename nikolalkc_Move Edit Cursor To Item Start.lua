--Select Item Under MouseCursor and Move EditCursor to Item Start

function Msg(param)
	--reaper.ShowConsoleMsg(tostring(param))
end

function Main()
	Msg("")
	reaper.Main_OnCommand(40528, 0)-- select item under cursor
	selected_item = reaper.GetSelectedMediaItem(0,0)

	if selected_item == nil then
		--Msg("PRAZNO")
	else
		item_pos = reaper.GetMediaItemInfo_Value(selected_item,"D_POSITION")
		cursor_pos =  reaper.GetCursorPosition()
		Msg("Item position:"..item_pos)
		Msg("\nCursor position:"..cursor_pos)
		
		delta = cursor_pos - item_pos
		reaper.MoveEditCursor(-delta, 0)
	end
	reaper.UpdateArrange()
end


Main()
