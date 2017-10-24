--SNF - Move Rendered Sounds to HOPA project

--[[ChangeLog
	* v.04 (2017-10-24)
		+Exceptioni i errori uradjeni
		
	* v.03 (2017-10-23)
		+Osvnovno radi
		
	* v.02 (2017-10-23)
		+Ho Logika
	
	* v.01 (2017-10-23)
		+Prekucavanje skripti
	

]]

--utility===================================================================================================================================================================
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

bounced_sounds_folder = [[D:\BouncedSounds\]]
sounds_to_move = {}
game_folders = {}
game_folder_paths = {}
last_export_folder = ""

function ScanSoundsToMove(post)
	--scan all files in D:\bounced sounds
	prog2 = [[dir "]]..bounced_sounds_folder..[[" /a:-d /b]]
	local idx = 0
	for sound_file in io.popen(prog2):lines() do
		--Msg(sound_file)
		--create array
		
		--remove extension from file name
		rid = string.reverse(sound_file)
		--Msg(rid)
		index1 = string.find(rid, "%.")
		--Msg(index1)
		rid_name = string.sub(rid, index1+1, -1)
		extension = string.sub(rid, 0, index1-1)
		extension = string.reverse(extension)
		--Msg(extension)
		dir_name = string.reverse(rid_name)
		--Msg(dir_name)
		
		
		if extension == "ogg" then	--ako je ogg, dodaj ga u listu za premestanje
			sounds_to_move[idx] = dir_name
			idx = idx + 1
		end
	end
	
	--debug print
	if post == true then
		Msg("\n===============")
		Msg("("..idx..")".." OGG sounds remaining in "..bounced_sounds_folder)
		Msg("")
	else
		Msg("\n===============")
		Msg("Scanning Sounds:\n")
	end
	--print them
	for i=0, idx-1 do
		Msg((i+1)..". "..sounds_to_move[i])
	end
end

function ScanFoldersInGameProjectFolder()
	Msg("\n===============")
	Msg("Scanning folders...\n")
	folder_idx = 0
	
	--list all directories in folder P:\data and exclude:  .svn _prefabs _resources _savegames _sounds===========================================================================================
	prog1 = [[dir "P:\data\" /b /s /a:d | findstr /v "\_interface"| findstr /v "\.svn"|findstr /v "\_prefabs"| findstr /v "\_resources"| findstr /v "\_savegames"| findstr /v "\_sounds"]]
	ScanSpecificFolders(prog1)

	--TODO: za interface posebna logika
	prog2 = [[dir "P:\data\_interface\inventory\" /b /s /a:d | findstr /v "\_sounds"]]
	ScanSpecificFolders(prog2)
	
	--exceptions za dodatne foldere, ručno ubačenui
	game_folder_paths[folder_idx] = [[P:\data\_interface\hud]]
	game_folders[folder_idx] = [[hud]]
	folder_idx = folder_idx + 1
	
	game_folder_paths[folder_idx] = [[P:\data\_interface\journal]]
	game_folders[folder_idx] = [[journal]]
	folder_idx = folder_idx + 1
	
	game_folder_paths[folder_idx] = [[P:\data\_interface\map]]
	game_folders[folder_idx] = [[map]]
	folder_idx = folder_idx + 1
	
	--debug print
	-- for i = 0, folder_idx - 1 do 
		-- Msg(game_folder_paths[i])
		---- Msg(game_folders[i])
	-- end

	Msg("Scan completed.")
end

function ScanSpecificFolders(prog) 
	for dir in io.popen(prog):lines() do 
		--get folder name
		rid = string.reverse(dir)
		index1 = string.find(rid, "\\" )
		rid_name = string.sub(rid, 0, index1-1)
		dir_name = string.reverse(rid_name)
			
		game_folders[folder_idx] = dir_name
		game_folder_paths[folder_idx] = dir
		folder_idx = folder_idx + 1
	end
end


function SeparateFolderAndFileName (name)
	local folder_name, file_name = name:match("([^,]+)-([^,]+)")
	return folder_name, file_name
end


function MoveSounds()
	Msg("\n===============")
	Msg("Moving Sounds...\n")
	--za svaki zvuk
	for i in pairs(sounds_to_move) do
		folder,filename = SeparateFolderAndFileName(sounds_to_move[i])
		
		if filename ~= nil then
			if folder == "game" then
				--move it to interface folder
				ExecuteMoveFile(sounds_to_move[i],filename,[[P:data\_interface\_sounds\]],"interface")
			else
				if folder == last_export_folder then --ako je isti folder kao prethodni
					--prebaci u isti folder kao prethodni
					ExecuteMoveFile(sounds_to_move[i],filename,last_export_folder_path,"last")
				else										 --ako treba da traži folder
					
					--provera dal je _ho folder
					ho_folder_name = ""
					
					is_ho_normal = string.sub (folder,-3,-1)
					if is_ho_normal == "_ho" then
						ho_folder_name = [[\ho]]
						folder = string.sub(folder,1, -4)
						--Msg("HO:"..folder)
					else  
						-- provera dal je  _ho_second ili _ho_nesto
						is_ho_other = string.find(folder,'_ho_')
						if is_ho_other ~= nil then
							ho_folder_name = string.sub(folder, is_ho_other, -1)
							folder = string.sub(folder,0,-(string.len(ho_folder_name)+1)) 	--oduzmi ho deo iz folder imena
							ho_folder_name = "\\"..string.sub(ho_folder_name,2,-1) 			--ovo se koristi posle sa prefiskom \
						end
					end

					
					
					--moveit normalno i stavi taj folder kao poslednji...
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
	--proveri da li samo ne postoji _sounds folder i napravi ga ako je to slucaj
	--izbaci gresku ako uopste ne postoji folder
	Msg("ERROR***********************************************")
	Msg("For:           "..sound)
	Msg("Folder does not exist:")
	Msg(path.."\nCheck for typos or create folder.")
	Msg("*********************************************************\n")
end

function ExecuteMoveFile(original_file,destination_file,full_final_path,source) --bez ekstenzije, bez ekstenzije, cela staza sa \ na kraju
	Msg(source)
	move_prog = [[move /y "]]..bounced_sounds_folder..original_file..[[.ogg" "]]..full_final_path..destination_file..[[.ogg"]]
	--Msg(move_prog)
	--io.popen(move_prog)
	-- for dir in io.popen(move_prog):lines() do
		-- Msg(dir)
	-- end
	
	
	done = os.execute(move_prog)
	Msg(done)
	
	if done == true then 
		Msg("_____________________________________________________")
		Msg("For:		"..original_file)
		Msg([[Create:		]]..destination_file.."\nIn path:		"..full_final_path)
		Msg("		(1) files moved.")
	else
		Exception(full_final_path,original_file)
	end
end



function Main()
	ScanSoundsToMove(false) --za pocetak
	ScanFoldersInGameProjectFolder()
	MoveSounds()
	ScanSoundsToMove(true) -- da proveri kolko je ostalo
	Msg("\n>>>> Moving Completed <<<<")
end


--upotreba
Main()
