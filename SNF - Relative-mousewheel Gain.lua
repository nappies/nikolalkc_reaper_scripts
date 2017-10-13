function run()
	is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
	if is_new then
		--reaper.ShowConsoleMsg(name .. "\nrel: " .. rel .. "\nres: " .. res .. "\nval = " .. val .. "\n")
		item = reaper.GetSelectedMediaItem( 0,0 )
		vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
		--reaper.ShowConsoleMsg(vol.."\n")
		if val > 0 then
			local new_vol = vol*1.2
			 reaper.SetMediaItemInfo_Value(item, "D_VOL", new_vol )
		else
			local new_vol = vol/1.2
			reaper.SetMediaItemInfo_Value( item, "D_VOL", new_vol )
		end
	end
	reaper.Main_OnCommand(40441,0) --rebuild peaks
end

run()