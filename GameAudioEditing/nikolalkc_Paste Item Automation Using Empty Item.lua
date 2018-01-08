--[[
  ReaScript Name: Paste item automation using empty item
  Description: This script pastes the automation values for all envelopes copied with empty item
  Instructions:Use first Copy Item Automation Using Empty Item and then select where you want to paste setting and
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
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
	reaper.Main_OnCommand(40058,0) --Item: Paste items/tracks
	reaper.Main_OnCommand(40290,0) --set time selection to items
	reaper.Main_OnCommand(40697,0) --Remove items/tracks/envelope points (depending on focus)

end



--RUN
reaper.PreventUIRefresh( 1 )
reaper.Undo_BeginBlock()
Main()
reaper.PreventUIRefresh( -1 )
reaper.UpdateArrange()
reaper.Undo_EndBlock("Paste item automation using empty item", -1)
