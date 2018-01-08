--[[
	ReaScript Name:Move Edit Cursor To Item Start
	Description:Moves edit cursor to begining of selected item
	Instructions: select item and run script
	Author: nikolalkc
	Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
	REAPER: 5+
	Extensions: SWS
	Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-12-28)
	+ Initial Release
--]]
--Select Item Under MouseCursor and Move EditCursor to Item Start

function Msg(param)
	--reaper.ShowConsoleMsg(tostring(param))
end

function Main()
	Msg("")
	reaper.Main_OnCommand(40528, 0)-- select item under cursor
	selected_item = reaper.GetSelectedMediaItem(0,0)

	if selected_item == nil then
		--Msg("nothing selected")
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
