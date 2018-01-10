--[[
  ReaScript Name: Triple zoom in (ProTools - T)
  Author: nikolalkc
  Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
  REAPER: 5+
  Version: 1.4
  About:
    # Triple Zoom In

    Zooms more like *Protools* when *T* key pressed.
    [Check it out](https://www.pro-tools-expert.com/home-page/2016/6/6/zooming-shortcuts)
]]

--[[
	* Changelog:
	* v1.4 (2017-12-29)
	  + INFO ADDED
  * v1.3 (2017-12-28)
    + Link added
  * v1.2 (2017-12-28)
    + About section added
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
	reaper.Main_OnCommand(1012,0) --zoom in horizontal
	reaper.Main_OnCommand(1012,0) --zoom in horizontal
	reaper.Main_OnCommand(1012,0) --zoom in horizontal

	reaper.PreventUIRefresh( -1 )
end
--RUN
Main()
