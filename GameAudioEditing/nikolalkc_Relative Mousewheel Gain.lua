--[[
 * ReaScript Name: RELATIVE MOUSEWHEEL GAIN
 * Description: Changes gain to selected items with scroll of mouse
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 * REAPER: 5.52
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-10-14)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

function run()
	is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
	selected_count = reaper.CountSelectedMediaItems(0)
	if selected_count <= 1 then
		--reaper.Main_OnCommand(40529,0) --select item under mouse leaving other items selected
		reaper.Main_OnCommand(40528,0) --select item under mouse
	end

	if selected_count > 0 then
		for i = 0, selected_count - 1 do
			if is_new then
				--reaper.ShowConsoleMsg(name .. "\nrel: " .. rel .. "\nres: " .. res .. "\nval = " .. val .. "\n")
				local item = reaper.GetSelectedMediaItem( 0,i )

				if item ~= nil then
					vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
					--reaper.ShowConsoleMsg(vol.."\n")
					if val > 0 then --if positive value
						local new_vol = vol*1.2
						 reaper.SetMediaItemInfo_Value(item, "D_VOL", new_vol )
					else --if it's negative value
						local new_vol = vol/1.2
						reaper.SetMediaItemInfo_Value( item, "D_VOL", new_vol )
					end
				end
			end
		end
	end

	--reaper.Main_OnCommand(40441,0) --rebuild peaks
end



reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
run() -- run script
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("Mousewheel Item Gain", -1)
reaper.UpdateArrange()
