--[[
  ReaScript Name: Envelope Printer - Copy item automation using empty item
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
  About:
    # Copy item automation using empty item
      This script simulates ProTools' option to copy all plugin parameters.
      WARNING: Beware of items with automation clips. Check your preferences and test behavior of this script for your configuration.
]]

--[[
 * Changelog:
 * v1.0 (2017-06-26)
	+ First Version
]]

--[[ ----- DEBUGGING ===>
	--reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"),0) --select items under edit cursor on selected tracks
]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

function Main()
	--proveri kolika je selekcija vremenska
	start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
	delta_time = end_time - start_time

	selected_count = reaper.CountSelectedMediaItems(0)
	if selected_count == 1 then
		if delta_time > 0 then
			--idi dalje
		else
			reaper.Main_OnCommand(40290,0) --set time selection to items
		end

		reaper.Main_OnCommand(40142,0) --Insert empty item
		cur_item = reaper.GetSelectedMediaItem(0,0)
		reaper.ULT_SetMediaItemNote( cur_item, "[AUTO]")
		reaper.Main_OnCommand(40699,0) --Cut items
		reaper.Main_OnCommand(40020,0) --Time selection: Remove time selection and loop points
	else
		retva = reaper.ShowMessageBox("You must select (only) one item.","Copy Item Automation Error",0)
	end
end



--RUN
reaper.PreventUIRefresh( 1 )
reaper.Undo_BeginBlock()
Main()
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("SNF - Copy item automation using empty item)", -1)
reaper.UpdateArrange()
