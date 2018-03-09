--[[
 ReaScript Name:MHG - Export Selected Sounds
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 REAPER: 5+
 Extensions: SWS
 Version: 1.54
 About:
  NOTE: MHG ONLY SCRIPT! Renders selected wGroups (which have been named properly) to desired folder and after that it moves files to HOPA/_sounds folders
  
  WARNING: Do not start your region names with * character, this script uses it for distinguishing render region from normal regions!
  
  WARNING 2: Do not use slot #16 for sws mute state, and selection set #10 because this script will override them!
  
  INSTRUCTIONS: Make item or time selection, time selection has priority, then run the script.

  RENDER SETTINGS: 

    SOURCE: Region render matrix

    FILENEME: $region
]]

--[[
 * Changelog:
 * v1.54 (2018-03-09)
	+ Fix: Regions that are wider than time selection but still overlap it will also be rendered, as expected
 * v1.53 (2018-03-08)
	+ Items that overlap initial time selection are also added to render list
	+ Using slot #10 for selection set instead of #01
 * v1.52 (2018-03-08)
	+ Testing change log in reapack index
 * v1.51 (2018-03-08)
	+ Info added, testing new change log format
 * v1.5 (2018-03-08)
	+ Completely changed rendering behavior to use render matrix instead of render queue.
 * v1.4 (2018-02-28)
	+ Added check for system variable that defines project type (MADBOX or WWISE)
 * v1.3 (2018-01-15)
	+ io.popen replaced with reascript functions for enumeration for files and folders
 * v1.2 (2017-11-30)
	+ support added for main_menu export folder
 * v1.1 (2017-10-30)
	+ support fo over_hud folder, special array for exceptions created
 * v1.0 (2017-10-24)
	+ MERGE Move Rendered Sounds To Project & Export Selected Clip Groups, they are now one script
 * v0.03 (2017-10-23)
	+ run lua script after rendering
	+ bounced_sounds_folder variable
	+ make_items_white variable
 * v0.02 (2017-08-17)
	+ colors become lighter after exporting, not white
 * v0.01 (2017-01-01)
	+ Export selected Wrap Groups to BouncedSounds folder and runs SNF - Move Rendered Sounds To Project.lua
	+ Clip group names must begin with '@' character
	+ Render settings must be set with dummy render to item-name @region and bounds to time selection
]]

--utility===================================================================================================================================================================
bounced_sounds_folder = [[D:\BouncedSounds\]]
active_project_type = os.getenv("ACTIVE_AUDIO_PROJECT")

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--colors---------------------------------------------------------------------------------------------
make_items_white = true
luminance_change_amount = 0.3
absolute_luminance = false --true for absolute, false for increment


--[[MOVE RENDERED SOUNDS TO PROJECT START+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
HISTORY
* v04 (2017-10-24)
	+Exceptions i errori done

* v03 (2017-10-23)
	+Basics work

* v02 (2017-10-23)
	+Ho Logics

* v01 (2017-10-23)
	+retyping
]]

sounds_to_move = {}
game_folders = {}
game_folder_paths = {}
last_export_folder = ""
interface_exceptions = {[[hud]],[[journal]],[[map]],[[over_hud]],[[main_menu]]}


function ScanSoundsToMove(post)
	if post == false then
		Msg([[Scanning sounds in ]]..bounced_sounds_folder)
		Msg("")
	end
	--scan all files in D:\bounced sounds

	--prog2 = [[dir "]]..bounced_sounds_folder..[[" /a:-d /b]]  --deprecated

	local idx = 0
	i = 1
	fileindex = 0
	while i ~= nil do
		i = reaper.EnumerateFiles( bounced_sounds_folder, fileindex )
		--Msg(fileindex)


		--create array
		if i ~= nil then
			--remove extension from file name
			rid = string.reverse(i)
			--Msg(rid)
			index1 = string.find(rid, "%.")
			--Msg(index1)
			rid_name = string.sub(rid, index1+1, -1)
			extension = string.sub(rid, 0, index1-1)
			extension = string.reverse(extension)
			--Msg(extension)
			dir_name = string.reverse(rid_name)
			--Msg(dir_name)


			if extension == "ogg" then	--if ogg, add it to  moving list
				sounds_to_move[idx] = dir_name
				idx = idx + 1
				Msg(i)
			end
		end
		fileindex = fileindex + 1
	end

	--debug print
	if post == true then
		Msg("\n===============")
		Msg("("..idx..")".." OGG sounds remaining in "..bounced_sounds_folder)
		Msg("")
	else
		Msg("\nScanning Sounds Completed!\n")
		Msg("===============")
	end
end

folder_idx = 0
function ScanSubdirectories(path)
	local subdirindex = 0
	local j = 1
	while j ~= nil do
		j = reaper.EnumerateSubdirectories( path, subdirindex )
		if j ~= nil and j ~= ".svn" and j ~= "_prefabs" and j ~= "_resources" and j ~= "_savegames" and j~= "_sounds" and j ~= "wallpapers_ce" then
			--recursive call
			local folder_path = path..j..[[\]]
			ScanSubdirectories(folder_path)
			--Msg(path..j)

			--add to array
			game_folders[folder_idx] = j
			game_folder_paths[folder_idx] = path..j
			folder_idx = folder_idx + 1
		end



		subdirindex = subdirindex + 1
	end
end


function SeparateFolderAndFileName (name)
	local folder_name, file_name = name:match("([^,]+)-([^,]+)")
	return folder_name, file_name
end

function MoveSounds()
	Msg("\n===============")
	Msg("Moving Sounds...\n")
	--for every sound
	for i in pairs(sounds_to_move) do
		folder,filename = SeparateFolderAndFileName(sounds_to_move[i])

		if filename ~= nil then
			if folder == "game" then
				--move it to interface folder
				ExecuteMoveFile(sounds_to_move[i],filename,[[P:data\_interface\_sounds\]],"interface")
			else
				if folder == last_export_folder then --if same folder as last
					--prebaci u isti folder kao prethodni
					ExecuteMoveFile(sounds_to_move[i],filename,last_export_folder_path,"last")
				else										 --if it should search folder

					--check if HO folder
					ho_folder_name = ""

					is_ho_normal = string.sub (folder,-3,-1)
					if is_ho_normal == "_ho" then
						ho_folder_name = [[\ho]]
						folder = string.sub(folder,1, -4)
						--Msg("HO:"..folder)
					else
						-- check if ho_second or ho_something
						is_ho_other = string.find(folder,'_ho_')
						if is_ho_other ~= nil then
							ho_folder_name = string.sub(folder, is_ho_other, -1)
							folder = string.sub(folder,0,-(string.len(ho_folder_name)+1)) 	--remove ho part from name
							ho_folder_name = "\\"..string.sub(ho_folder_name,2,-1) 			--this is later used with prefix \
						end
					end



					--move it normal and set folder as last
					local folder_found = false
					for j in pairs(game_folders) do
						if game_folders[j] == folder then
							path_for_export = game_folder_paths[j]..ho_folder_name..[[\_sounds\]]
							last_export_folder = game_folders[j]
							last_export_folder_path = path_for_export
							ExecuteMoveFile(sounds_to_move[i],filename,path_for_export,"data")
							folder_found = true
							break
						end

					end

					if folder_found == false then
						Exception((folder..ho_folder_name),sounds_to_move[i])
					end
					Msg(" ")
				end
			end
		end
	end
end

function Exception(path,sound)
	--check if _sounds does not exist and create it if that's the case
	--error if there is no folder at all
	Msg("ERROR***********************************************")
	Msg("For:           "..sound)
	Msg("Folder does not exist:")
	Msg(path.."\nCheck for typos or create folder.")
	Msg("*********************************************************\n")
end

function ExecuteMoveFile(original_file,destination_file,full_final_path,source) --no extension, no extension, whole path with \ at the end
	--Msg(source)
	move_prog = [[move /y "]]..bounced_sounds_folder..original_file..[[.ogg" "]]..full_final_path..destination_file..[[.ogg"]]
	--Msg(move_prog)

	done = os.execute(move_prog)
	--Msg(done)

	if done == true then
		Msg("_____________________________________________________")
		Msg("For:		"..original_file)
		Msg([[Create:		]]..destination_file.."\nIn path:		"..full_final_path)
		Msg("		(1) files moved.")
	else
		Exception(full_final_path,original_file)
	end
end

function MOVE_RENDERED_SOUNDS_TO_PROJECT()
	ScanSoundsToMove(false) --for start

	Msg([[Scanning Folders in P:\data]])
	ScanSubdirectories([[P:\data\]])
	Msg("Scanning Folders Completed!")

	MoveSounds()
	ScanSoundsToMove(true) -- to check how many remained after moving
	Msg("\n>>>> Moving Completed <<<<")
end

--[[MOVE RENDERED SOUNDS TO PROJECT END+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
]]


--colors utility---------------------------------------------------------------------------------------------
function MakeItemColorBrighter(item)
	local color = reaper.GetDisplayedMediaItemColor(item)
	local R, G, B = reaper.ColorFromNative(color|0x1000000)
	local new_r, new_g, new_b = Luminance(luminance_change_amount, R, G, B)
	local con_r, con_g, con_b = Convert_RGB(new_r,new_g,new_b)
	local new_color = reaper.ColorToNative(con_r,con_g,con_b)|0x1000000
	ApplyColor_Items(new_color,item)
end

function Convert_RGB(ConvertRed,ConvertGreen,ConvertBlue)
	red = math.floor(ConvertRed*255 )
	green = math.floor(ConvertGreen*255 )
	blue =  math.floor(ConvertBlue*255 )
	ConvertedRGB = reaper.ColorToNative (red, green, blue)
	return red, green, blue
end

function hex2rgb(hex)
	  hex = hex:gsub("#","")
	  hex2rgbR = tonumber("0x"..hex:sub(1,2))
	  hex2rgbG = tonumber("0x"..hex:sub(3,4))
	  hex2rgbB = tonumber("0x"..hex:sub(5,6))
end

function Luminance(change, red, green, blue)
  local hue, sat, lum = rgbToHsl(red/255, green/255, blue/255)
  if absolute_luminance == true then
	lum = change
  else
    lum = lum + change
  end
  local r, g, b = hslToRgb(hue, sat, lum)
  if r<=0 then r = 0 end ; if g<=0 then g = 0 end ; if b<=0 then b = 0 end
  if r>=1 then r = 1 end ; if g>=1 then g = 1 end ; if b>=1 then b = 1 end
  return r, g, b
end

function rgbToHsl(r, g, b) -- values in-out 0-1
      local max, min = math.max(r, g, b), math.min(r, g, b)
      local h, s, l
      l = (max + min) / 2
      if max == min then
        h, s = 0, 0 -- achromatic
      else
        local d = max - min
        if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
        if max == r then
          h = (g - b) / d
          if g < b then h = h + 6 end
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4
        end
        h = h / 6
      end
      return h, s, l or 1
end

function hslToRgb(h, s, l) -- values in-out 0-1
  local r, g, b
  if s == 0 then
	r, g, b = l, l, l -- achromatic
  else
	function hue2rgb(p, q, t)
	  if t < 0   then t = t + 1 end
	  if t > 1   then t = t - 1 end
	  if t < 1/6 then return p + (q - p) * 6 * t end
	  if t < 1/2 then return q end
	  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	  return p
	end
	local q
	if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
	local p = 2 * l - q
	r = hue2rgb(p, q, h + 1/3)
	g = hue2rgb(p, q, h)
	b = hue2rgb(p, q, h - 1/3)
  end
  return r,g,b
end

function ApplyColor_Items(new_color,item)
	reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",new_color)
	reaper.UpdateItemInProject(item)
end
--colors utility end---------------------------------------------------------------------------------------------


--array defs================================================================================================================================================================
item = {}
take = {}
name = {}
item_pos = {}
item_len = {}
item_is_empty = {}
clip_group = {}
overlapping_items = {}
overlapping_items_mute_state = {}
ov_index = 0
cg_index = 0
selected_count = nil

--Main FUN==================================================================================================================================================================
function Main()
	reaper.Undo_BeginBlock()
	--check time selection
	start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
	delta_time = end_time - start_time

	if delta_time > 0 then     --there is time selection
		--export
		reaper.Main_OnCommand(40717,0) --Item: Select all items in current time selection
		-- reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items
		
		--update time selection values
		start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
		delta_time = end_time - start_time
		
		selected_count = reaper.CountSelectedMediaItems(0)
		create_regions_and_sort_them()
		manage_regions()
		post_export_dialog()

	else --no time selection

		--check item selection
		selected_count = reaper.CountSelectedMediaItems(0)
		if selected_count == 0 then --no items selected
			--Msg("No items selected. You must select at least one item, or make time selection")
			post_export_dialog("No Items Selected!")
		else --if at least one item selected
			--export
			reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items
			start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
			delta_time = end_time - start_time
			
			create_regions_and_sort_them()
			manage_regions()
			post_export_dialog()
		end
	end
	reaper.Undo_EndBlock("nikolalkc_MHG - Render Selected wGroups", -1)
	reaper.UpdateArrange()
end

--RENDER MATRIX MANAGE REGIONS=================================================================================================================================================================
function create_regions_and_sort_them()
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SAVE_SOLO_MUTE_ALL_ITEMS_SLOT_16"),0) --SWS/BR: Save all items' mute state, slot 16
	reaper.Main_OnCommand(41238,0) -- save selection set #10
	reaper.Main_OnCommand(40182,0) -- Item: Select all items
	reaper.Main_OnCommand(40719,0) -- Item properties: Mute
	reaper.Main_OnCommand(41248,0) -- Selection set: Load set #10
	
	for i = 0, selected_count - 1 do
	
		--get stuff from item
		item[i] = reaper.GetSelectedMediaItem(0,i)
		take[i] = reaper.GetMediaItemTake(item[i], 0)
		if take[i] ~= nil then
			name[i] =  reaper.GetTakeName(take[i])
		else
			item_is_empty[i] = true
			name[i] = reaper.ULT_GetMediaItemNote(item[i])
			name[i] = string.gsub (name[i], "\n", "")
			name[i] = string.gsub (name[i], "\r", "")
		end


		--make new array with items that begin with '@'
		local first_string = string.sub(name[i], 1, 1)
		if first_string == "@" then
			clip_group[cg_index] = item[i]
			cg_index = cg_index + 1

			--DEPRECATED -- action is used instead later
			-- -- color item to white
			-- local white = reaper.ColorToNative(255,255,255)|0x1000000
			-- reaper.SetMediaItemInfo_Value( item[i], "I_CUSTOMCOLOR", white)
			-- -- Msg(name[i])
		end
	end


	--Msg("Clip Groups:"..cg_index)
	reaper.Main_OnCommand(40289,0) --Item: Unselect all items

	--run through new array and create and sort regions by level
	dictionary = {}
	for i = 0, cg_index - 1 do
		reaper.SetMediaItemSelected( clip_group[i], 1 )
		reaper.Main_OnCommand(40290,0) --Time selection: Set time selection to items


		--get stuff
		local item_pos = reaper.GetMediaItemInfo_Value(clip_group[i],"D_POSITION")
		local item_len = reaper.GetMediaItemInfo_Value(clip_group[i],"D_LENGTH")
		-- local group_id = reaper.GetMediaItemInfo_Value(clip_group[i],"I_GROUPID")
		local take = reaper.GetMediaItemTake(clip_group[i], 0)
		local item_end = item_pos + item_len
		local name = ""
		if take ~= nil then		--if regular item
			name =  reaper.GetTakeName(take)
		else	--if emtpy item
			name = reaper.ULT_GetMediaItemNote( clip_group[i])
			name = string.gsub (name, "\n", "")
			name = string.gsub (name, "\r", "")
		end
		
		local changed_name = string.sub(name, 2)
		local value = string.gsub(changed_name, "%:", "-") --replace (:) with (-)
		local new_name = "*"..value	--add specific prefix
		local red = reaper.ColorToNative(255,0,0)|0x1000000


		--create region with same name as clip group
		local marker_index = reaper.AddProjectMarker2( 0, 1, item_pos, item_end, new_name, 0, red )
		for_index = Get_ForIndex_by_MarkerIndex(marker_index)
		dictionary[value] = clip_group[i]
	
		reaper.Main_OnCommand(40289,0) --Item: Unselect all items
	
		--set original time selection
		startOut, retval, endOut =  reaper.GetSet_LoopTimeRange( true, true, start_time, end_time, true)
		
	end

	OgranizeRegions()

end


function manage_regions() --render or add to render queue depenging on project type(MADBOX,WWISE)
	local master_track =  reaper.GetMasterTrack( 0 )
	
	--line by line
	for i = 0, MAX_REGION_LEVEL do
	
		--put whole line in render matrix
		reaper.Main_OnCommand(40289,0) --Item: Unselect all items
		for j in pairs (region_level[i]) do
			--get region
			local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(region_level[i][j])
			local item = dictionary[nameOut]
			
			--put regions in matrix
			if markrgnindexnumberOut ~= nil then
				reaper.SetRegionRenderMatrix( 0, markrgnindexnumberOut, master_track, 1 )
				
				--select all label items
				if item ~= nil then
					reaper.SetMediaItemSelected( item, true )				
				end
			end
		end

		--unmute line, because they have previoulsy been muted by this script
		reaper.Main_OnCommand(40034,0) --Item grouping: Select all items in groups
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_WHITEITEM"),0) --Set selected item's colors to white
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_SEL_ITEMS_SLOT_16"),0) --SWS/BR: Restore items' mute state to selected items, slot 16
		
		
		--manage regions - render or add to queue
		if region_level[i][1] ~= nil then
			if active_project_type == "WWISE" then
				reaper.Main_OnCommand(41823,0) --File: Add project to render queue, using the most recent render settings
			else	--if MADBOX or undefined
				reaper.Main_OnCommand(41824,0) --render using last render setting
				-- Msg("Rendering row:"..i.. " completed!")
			end
		end
		
		reaper.Main_OnCommand(40182,0) -- Item: Select all items
		reaper.Main_OnCommand(40719,0) -- Item properties: Mute
		reaper.Main_OnCommand(40289,0) --Item: Unselect all items
		
		--remove regions from matrix
		for l in pairs (region_level[i]) do
			local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(region_level[i][l])
			reaper.SetRegionRenderMatrix(0,markrgnindexnumberOut,master_track,-1)
		end
	end

	-- PrintLevelState()
	--put all regions in one array
	local buffer = {}
	for q = 0, MAX_REGION_LEVEL do
		for k in pairs (region_level[q]) do
			local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(region_level[q][k])
			table.insert(buffer,markrgnindexnumberOut)
		end
	end
	
	--delete regions at once
	for a in pairs(buffer) do
			reaper.DeleteProjectMarker( 0, buffer[a], true )
	end
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_ITEMS_SLOT_16"),0) --SWS/BR: Restore items' mute state to all items, slot 16

	
	-- Msg("after delete")
	-- PrintLevelState()
end

function OgranizeRegions() 
	--get all markers count
	all_markers_count, num_markersOut, num_regionsOut  = reaper.CountProjectMarkers( 0 )

	--get time selection
	local start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
	local delta_time = end_time - start_time
	
	
	
	if delta_time ~= 0 then					--if time selection exists
		for k = 0, MAX_REGION_LEVEL do		--for all newly created regions
			for i = 0, all_markers_count - 1 do 
				local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers2(0, i )
				if isrgnOut and string.sub(nameOut,0,1) == "*" then	--only if it is region that starts with *
					-- if posOut >= start_time and rgnendOut <= end_time then		--DEPRECATED:only if regions are inside (old version)
					if (rgnendOut >= start_time and rgnendOut <= end_time)  -- if region ends inside time selection
					or (posOut >= start_time and posOut <= end_time)		-- if region starts inside time selection
					or (posOut <= startOut and rgnendOut >= end_time) then	-- if region is wider than time selection but still overlaps it
						local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers2(0, i ) -- i fors ENUM
						UpdateRegionLevel(i)
					end
				end
			end	
		end
		
	end
	
	
	
	for i = 0, MAX_REGION_LEVEL do
		for k in pairs (region_level[i]) do
			local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(region_level[i][k])
			local original_name = string.sub(nameOut,2,-1)
			-- Msg(original_name)
			reaper.SetProjectMarker2(0,markrgnindexnumberOut,true,posOut,rgnendOut,original_name)
		end
	end
	-- PrintLevelState()
end


function Get_ForIndex_by_MarkerIndex(marker_index)	--forIndex is for all regions and markers together, marker_index is region's or marker's specific index
	local all_markers_count, num_markersOut, num_regionsOut  = reaper.CountProjectMarkers( 0 )
	for i=0, all_markers_count-1 do
		local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(i)
		if markrgnindexnumberOut == marker_index then
			for_index = i
			break
		end
	end
	return for_index
end


function PrintLevelState()
	Msg("")
	Msg("")
	for i = 0, MAX_REGION_LEVEL do
		Msg([[REGION LEVEL ]]..i..[[:]])
		for k in pairs (region_level[i]) do
			 local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers2(0, region_level[i][k])
			 GetRegionLevel(region_level[i][k])
			 Msg(region_level[i][k].."         "..nameOut)
			 -- Msg(dictionary[nameOut])
		end
	end
end

level = {}
level[0] = reaper.ColorToNative(200,150,100)|0x1000000
level[1] = reaper.ColorToNative(0  ,150,150)|0x1000000
level[2] = reaper.ColorToNative(200,200,0  )|0x1000000
level[3] = reaper.ColorToNative(200,0  ,100)|0x1000000
level[4] = reaper.ColorToNative(0  ,0  ,100)|0x1000000
level[5] = reaper.ColorToNative(60 ,30 ,100)|0x1000000
level[6] = reaper.ColorToNative(80 ,100,100)|0x1000000
level[7] = reaper.ColorToNative(0  ,0  ,200)|0x1000000
level[8] = reaper.ColorToNative(200,150,100)|0x1000000
level[9] = reaper.ColorToNative(0  ,150,150)|0x1000000
level[10]= reaper.ColorToNative(200,200,0  )|0x1000000
level[11]= reaper.ColorToNative(200,0  ,100)|0x1000000
level[12]= reaper.ColorToNative(0  ,0  ,100)|0x1000000
level[13]= reaper.ColorToNative(60 ,30 ,100)|0x1000000
level[14]= reaper.ColorToNative(80 ,100,100)|0x1000000
level[15]= reaper.ColorToNative(0  ,0  ,200)|0x1000000

--init arrays
region_level = {}
MAX_REGION_LEVEL = 14 -- starts at zero
for i = 0,MAX_REGION_LEVEL do		
	region_level[i] = {}
end
-----
	

function setLevel(for_index,layer)
	--if not already on list put it on list
	local not_on_list = true
	if region_level[layer] ~= nil then
		for k in pairs (region_level[layer]) do
			if region_level[layer][k] == for_index then
				not_on_list = false
				break
			end
		end
		if not_on_list then
			table.insert(region_level[layer],for_index)
			local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers2(0, for_index ) -- i for ENUM
			if string.sub(nameOut,0,1) ~= "*" then
				new_name = "*"..nameOut
			else
				new_name = nameOut
			end
			reaper.SetProjectMarker3(0,markrgnindexnumberOut,isrgnOut,posOut,rgnendOut,new_name,level[layer])
		end
	end
end

function removeFromLevel(for_index,layer)
	--find element and delete it, duplicates also
	for k in pairs (region_level[layer]) do
		if region_level[layer][k] == for_index then
			table.remove(region_level[layer],k)
		end
	end	

	
end



function UpdateRegionLevel(for_index)
	--get this region info
	local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(for_index) -- i za ENUM
	-- Msg("")
	--get current region level
	local this_region_level = GetRegionLevel(for_index)
	-- Msg("UpdateRegionLevel for:"..nameOut..[[(]]..this_region_level..[[)]])
	
	--find if there is free space in lower levels, starting from level 0 and then break when you find free space
	if this_region_level ~= "UNKNOWN" then
		for i = 0, this_region_level do
			-- Msg("Comparing level:"..i)
			this_level_is_blocked = false
			for k in pairs (region_level[i]) do
				local cValue, cIsRegion, cPos, cEnd, cName, cMarkerIndex = reaper.EnumProjectMarkers(region_level[i][k])
				if  markrgnindexnumberOut ~= cMarkerIndex then--do not compare with self
					if rgnendOut > cPos then							--check only if region is left from ending of current
						-- Msg("Comparing:"..nameOut.." with "..cName)
						if posOut < cEnd  then --if they overlap	maybe use <=	
							-- Msg("OOPS, REGIONS OVERLAP")
							this_level_is_blocked = true
							if i == this_region_level then--if they overlap with region on same level
								if posOut > cPos then
									-- Msg("Move to new level")
									removeFromLevel(for_index, this_region_level) --move to next level
									this_region_level = this_region_level + 1
									break
								elseif posOut == cPos then
									if markrgnindexnumberOut > cMarkerIndex then
										removeFromLevel(for_index, this_region_level) --move to next level
										this_region_level = this_region_level + 1
									end
								else
									-- Msg("leave it here")
								end
							else
								-- Msg("Continue Searching")
							end
						else
							-- Msg("No overlap")
						end
					else
						-- Msg("Region "..cName.." is right of region "..nameOut) --WHAT IF REGIONS OVERLAP HERE ON SAME LEVEL ???
					end
				else
					-- Msg("Don't compare with self")
				end
			end
			--check state after searching through this level
			if this_level_is_blocked == false then
				-- Msg("Space is free on level:"..i)
				-- Msg("Setting new Level")
				removeFromLevel(for_index,this_region_level) --remove region from current level
				this_region_level = i
				break
			end
		end
	else
		setLevel(for_index,0) --first time setting
	end
	
	--set new level
	setLevel(for_index,this_region_level)
	
end




function GetRegionLevel(for_index)
	local retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut = reaper.EnumProjectMarkers(for_index) -- i for ENUM
	result = "UNKNOWN"
	for i = 0, MAX_REGION_LEVEL do
		for k in pairs (region_level[i]) do
			if region_level[i][k] == for_index then
				result =  i
				break
			end
		end
	end
	-- Msg(nameOut..[[ is on level: ]]..result)
	return result
end




--other fun=================================================================================================================================================================
function post_export_dialog(message_title)
	if active_project_type ~= "WWISE"  then	--if madbox or undefined
		if message_title == nil then message_title = [[Rendering Completed]] end
		-- --When rendering completed======================================================================
		ok = reaper.ShowMessageBox( [[Do you want to move rendered sounds to P:\data ?

	Pressing No will open ]]..bounced_sounds_folder, message_title, 3 )
		--Msg(ok)

		--Yes clicked --run move script=============================
		if ok == 6 then
			--move script
			MOVE_RENDERED_SOUNDS_TO_PROJECT()
		end

		--No clicked --open folder==================================
		if ok == 7 then
			prog = [[%SystemRoot%\explorer.exe "]]..bounced_sounds_folder..[["]]
			os.execute(prog)
		end
		--=================================================================================================
	else	--ako je wwise
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_actionOpenTransferWindow"),0) --Open WAAPI transfer window.
	end
end




--EXECUTION=================================================================================================================================================================
-- reaper.PreventUIRefresh( 1 )
Main() -- run script
-- reaper.PreventUIRefresh( -1 )