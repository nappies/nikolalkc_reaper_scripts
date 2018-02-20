--[[
 ReaScript Name: MHG - Set Item Name To Text Copied From Localization
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5.75
 Version: 0.1
 About:
	Uses text copied from localization_en.txt and formats it to wGroup naming convention.
]]

--[[
 * Changelog:
 * v1.0 (2018-02-19)
	+ Initial Release
]]


--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


--MAIN FUNCTION
function Main()
	clipboard = reaper.CF_GetClipboard('')
	a = string.find(clipboard, '\t', 1)
	short = [[@]]..string.sub(clipboard,0,a)
	final_name = string.gsub(short,":",":\nvo_")


	cur_item = reaper.GetSelectedMediaItem(0,0)
	reaper.ULT_SetMediaItemNote( cur_item, final_name)
	ToggleNoteStretchToFit(cur_item)
end


  --TOGGLE NOTE STRETCH TO FIT WITH LUA
function ToggleNoteStretchToFit(item)
  local strNeedBig = ""
  retval, strNeedBig = reaper.GetItemStateChunk( item, strNeedBig, false )
  -- Msg(strNeedBig)
  -- Msg("=====================================================")
  NoteStretchState = string.match(strNeedBig, "IMGRESOURCEFLAGS %d")
  
  -- TURN ON
  new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 2") --turn on stretch
  
  --TOGGLE
  -- if NoteStretchState == "IMGRESOURCEFLAGS 0" then
    -- new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 2") --turn on stretch
  -- else
    -- new_state = string.gsub(strNeedBig, "IMGRESOURCEFLAGS %d", "IMGRESOURCEFLAGS 0") --turn off stretch
  -- end

  reaper.SetItemStateChunk( item, new_state, true )

  end

--RUN
Main()
reaper.UpdateArrange()
