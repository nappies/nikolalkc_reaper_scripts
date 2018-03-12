
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


