--[[
 ReaScript Name:  MHG Check Dependencies
 Author: nikolalkc
 Repository URL: https://github.com/nikolalkc/AutoHotKey_Macros/tree/master/Reaper%20Scripts
 REAPER: 5+
 Version: 1.7
 About:
  Checks for source of all audio files in project and if they are not from Q: partition copies files in project directory
  Instructions: Use it with your Saving shortcut, replace default (CTRL+S)
]]

--[[
 * Changelog:
 * v1.7 (2017-12-28)
  + Check for offline files and skip them for copying
 * v1.6 (2017-12-27)
	+ Checking for offline files started, disabled, because it is too slow *********
 * v1.5 (2017-12-26)
	+ If there are hidden tracks, show them before save, indluce files from them, and hide them after saving, works with TCP and MCP linked
 * v1.4 (2017-12-26)
	+ Overwrite all new for XCOPY
 * v1.3 (2017-12-21)
	+ Replaced S: partition with Q: partition
 * v1.2 (2017-12-14)
	+ Removed exception for videos, they are now also copied
 * v1.1 (2017-05-26)
	+ Support for unsaved projects
	+ Added exception for empty items and rpr files
 * v1.0 (2017-?-?)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--MEAT
item = {}
take = {}
name = {}
src = {}
filepath = {}
filename = {}
relocate_item = {}

audio_idx = 0
s_drive_item_count = 0
project_item_count = 0
relocate_item_count = 0
video_item_count = 0
initially_visible_tracks = {}
unavailable_source_files = {}
usf_INDEX = 0

function CheckDependencies()

	--Get Project Path
	retval, project_path_and_filename = reaper.EnumProjects(-1, "")
	if project_path_and_filename ~= "" then
		project_path = GetPath(project_path_and_filename,"\\")						--store project path

		--remember visible tracks and show all tracks***************************************

		reaper.Main_OnCommand(40296,0) -- select all tracks

		--create array from currently visible tracks
		selected_tracks_count = reaper.CountSelectedTracks(0)
		for i = 0, selected_tracks_count -1 do
			initially_visible_tracks[i] = reaper.GetSelectedTrack(0,i)
			local track_name = ""
			retval, track_name = reaper.GetTrackName( initially_visible_tracks[i],track_name  )
			--Msg(track_name)
		end


		--show all tracks
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSTL_SHOWALL"),0) 		--SWS: Show all tracks
		--******************************************************************************************


		--Select all items
		reaper.Main_OnCommand(40182,0) 																						--Item: Select all items



		--get stuff from items
		selected_count = reaper.CountSelectedMediaItems(0)
		for i = 0, selected_count -1 do
			cur_item = reaper.GetSelectedMediaItem(0,i)
			cur_take = reaper.GetMediaItemTake(cur_item, 0)

			if cur_take ~= nil then
				is_midi = reaper.TakeIsMIDI(cur_take)

				if is_midi == false then																							--if not MIDI take
					item[audio_idx] = reaper.GetSelectedMediaItem(0,i)
					take[audio_idx] = reaper.GetMediaItemTake(item[audio_idx], 0)
					name[audio_idx] =  reaper.GetTakeName(take[audio_idx])
					src[audio_idx] = reaper.GetMediaItemTake_Source(take[audio_idx])
					filepath[audio_idx] = reaper.GetMediaSourceFileName(src[audio_idx],"")

					-- reaper.ShowConsoleMsg("Name:     ")
					-- Msg(name[audio_idx])

					-- reaper.ShowConsoleMsg("Src:         ")
					-- Msg(src[audio_idx])



					if filepath[audio_idx] == "" or filepath[audio_idx] == nil then
						parent = reaper.GetMediaSourceParent(src[audio_idx])
						filepath[audio_idx] = reaper.GetMediaSourceFileName(parent,"")

						-- reaper.ShowConsoleMsg("Parent Path:   ")
						-- Msg(filepath[audio_idx])
					else
						-- reaper.ShowConsoleMsg("Filepath:   ")
						-- Msg(filepath[audio_idx])
					end




          --check if there is file at given path, if is non existent, put it in array
					--**********************************************************************************
          ret = reaper.file_exists(filepath[audio_idx])
					if ret == false then
						Msg([[FILE DOES NOT EXIST AT THIS LOCATION: 	]]..filepath[audio_idx])

						--add file to array of offline files
						unavailable_source_files[usf_INDEX] = filepath[audio_idx]
						usf_INDEX = usf_INDEX + 1
					end
					--**********************************************************************************



					--make filename
					rid = string.reverse(filepath[audio_idx])
					--reaper.ShowConsoleMsg("Rid:")
					--Msg(rid)

					index1 = string.find(rid, "\\" )

					rid_name = string.sub(rid, 0, index1-1)
					filename[audio_idx] = string.reverse(rid_name)
					--Msg(filename[i])
					audio_idx = audio_idx +1
					--Msg(" ")

				end
			else
				--Msg("FILE NIL") --empty item
			end
		end

		-- --Check for all selected items
		--Msg("Status:===========================================================================")
		for i = 0, audio_idx -1 do
			file_path = GetPath(filepath[i],"\\")

			ln = string.len(project_path)
			reduced_file_path = string.sub(file_path,0,ln) 																	--make string with same length as project file, to check if file is somewhere deeper in project folder

			if reduced_file_path == project_path then																		  --@check if file is in project folder
				project_item_count = project_item_count + 1																	--it is somewhere in project folder
			else 																											                     --NOT IN PROJECT FOLDER
				s_drive = [[Q:\]]
				reduced_file_path2 = string.sub(file_path,0,3) 																--3 because Q:\ drive is of length of 3
				if reduced_file_path2 == s_drive then 																  		--@check if file is on virtual paritition S:\
					s_drive_item_count = s_drive_item_count + 1																--its ok, dont move file
				else 																										                   --file is not in SFX library, NEEDS TO BE MOVED IF AUDIO

					--check if video
					--filetype = reaper.GetMediaSourceType(src[i],"")
					--if filetype == "VIDEO" then
						--skip this file
					--else

						--check if offline
						local is_offline = false
						for j in pairs(unavailable_source_files) do
							--Msg(j..[[----]]..unavailable_source_files[j]..[[---]]..file_path[i])
							if unavailable_source_files[j] == filepath[i] then
								is_offline = true
								break
							end
						end

						if is_offline == false then
							Msg(name[i].."   --- SHOULD BE COPIED INTO PROJECT FOLDER")
							relocate_item[relocate_item_count] = item[i]
							relocate_item_count = relocate_item_count + 1
						end

					--end
				end
			end
		end
		-- Msg("===========================================================================")
		-- Msg(audio_idx.." non MIDI items.")
		-- Msg(project_item_count.." items located inside project folder.")
		-- Msg(s_drive_item_count.." items located on virtutal Q drive")
		-- Msg(relocate_item_count.." items that should be copied into project folder")



		if relocate_item_count > 0 then

		--TODO: provera da li treba da li ima vise istih fajlova

		message = [[	]]..project_item_count..[[ items located inside project folder.
	]]..s_drive_item_count..[[ items located on virtual Q drive.
	]]..relocate_item_count..[[ ITEMS THAT SHOULD BE COPIED INTO PROJECT FOLDER.

	Do you want to copy ]]..relocate_item_count..[[ files to project folder and replace item source?]]


			message_title = "WHAT TO DO?"
			ok = reaper.ShowMessageBox( message, message_title, 4 )
			if ok == 6 then
				--COPY FILES
				for i = 0, audio_idx -1 do
					file_path = GetPath(filepath[i],"\\")
					ln = string.len(project_path)
					reduced_file_path = string.sub(file_path,0,ln)
					if reduced_file_path ~= project_path then
						s_drive = [[Q:\]]
						reduced_file_path2 = string.sub(file_path,0,3)
						if reduced_file_path2 ~= s_drive then
							--COPYYYYY after video check
							--filetype = reaper.GetMediaSourceType(src[i],"")
							--if filetype == "VIDEO" then
								--skip this file
							--else
								--copy file to project folder and skip overwriting
								new_path = project_path..[[Assets\]]..filename[i]
								prog = [[xcopy ]]..[["]]..filepath[i]..[[" "]]..project_path..[[Assets\" /y /d]]
								os.execute(prog)

								--replace source
								reaper.BR_SetTakeSourceFromFile2(take[i],new_path,false,true)
								reaper.Main_OnCommand(40047,0) --build any missing peaks
							--end
						end
					end
				end
				reaper.Main_OnCommand(40026,0) --File: Save project
			else
				reaper.Main_OnCommand(40026,0) --File: Save project
			end
		else
			reaper.Main_OnCommand(40026,0) --File: Save project
			-- Msg(audio_idx.." non MIDI items.")
			-- Msg(project_item_count.." items located inside project folder.")
			-- Msg(s_drive_item_count.." items located on virtutal Q drive")
			-- Msg(relocate_item_count.." items that should be copied into project folder")
		end




		--**********************************************************************
		--show only previoulsy visible tracks
		reaper.Main_OnCommand(40297,0) --unselect all tracks
		for i = 0, selected_tracks_count -1 do
			reaper.SetTrackSelected( initially_visible_tracks[i], true )
		end

		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_TOGTRACKSEL"),0) 		--SWS: Invert track selection

		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSTL_HIDE"),0) 		--SWS: Hide Selected tracks
		--***********************************************************************


		reaper.Main_OnCommand(40289,0) --Item: Unselect all items
		reaper.Main_OnCommand(40026,0) --File: Save project
	else
		--Msg("NOT SAVED")
		reaper.Main_OnCommand(40026,0) -- save project
	end




end

function GetPath(str,sep)
    return str:match("(.*"..sep..")")
end



--MAIN FUNCTION
function Main()
	CheckDependencies()
	reaper.UpdateArrange()
end
--RUN
Main()
