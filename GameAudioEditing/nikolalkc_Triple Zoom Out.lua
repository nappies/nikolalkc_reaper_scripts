--[[
  ReaScript Name: Triple zoom out
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Version: 1.1
  About:
    Pro Tools like zoom out (R)
]]

--[[
 * Changelog:
	* v1.1 (2017-06-13)
		+ Support for horizontal zoom center to edit cursor
	* v1.0 (2017-05-31)
		+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--MEAT

--MAIN FUNCTION
function Main()
	reaper.PreventUIRefresh( 1 )

	reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITCUR"),0) --SWS/wol: Options - Set "Horizontal zoom center" to "Edit cursor"
	reaper.Main_OnCommand(1011,0) --zoom out horizontal
	reaper.Main_OnCommand(1011,0) --zoom out horizontal
	reaper.Main_OnCommand(1011,0) --zoom out horizontal

	reaper.PreventUIRefresh( -1 )
end
--RUN
Main()
