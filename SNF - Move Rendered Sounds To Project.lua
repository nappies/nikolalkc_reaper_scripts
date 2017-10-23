--SNF - Move Rendered Sounds to HOPA project

--[[ChangeLog
	* v.02 (2017-10-23)
		+Ho Logika
	
	* v.01 (2017-10-23)
		+Prekucavanje skripti
	

]]

--utility===================================================================================================================================================================
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

bounced_sounds_folder = "D:\\BouncedSounds\\"
sounds_to_move = {}
game_folders = {}
game_folder_paths = {}
last_export_folder = ""

function ScanSoundsToMove()
	--scan all files in D:\bounced sounds
	prog2 = [[dir "D:\BouncedSounds\" /a:-d /b]]
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
	Msg("\n===============")
	Msg("Scanning Sounds:\n")
	for i=0, idx-1 do
		Msg((i+1)..". "..sounds_to_move[i])
	end
end

function ScanFoldersInGameProjectFolder()
	--list all directories in folder P:\data and exclude:  .svn _prefabs _resources _savegames _sounds===========================================================================================
	--TODO: za ho posebna logika
	--TODO: za interface posebna logika
	--TODO: za hud posebna logika
	prog = [[dir "P:\data\" /b /s /a:d | findstr /v "\_interface"| findstr /v "\.svn"|findstr /v "\_prefabs"| findstr /v "\_resources"| findstr /v "\_savegames"| findstr /v "\_sounds"]]
	Msg("\n===============")
	Msg("Scanning folders...\n")
	local idx = 0
	for dir in io.popen(prog):lines() do 
		--get folder name
		rid = string.reverse(dir)
		index1 = string.find(rid, "\\" )
		rid_name = string.sub(rid, 0, index1-1)
		dir_name = string.reverse(rid_name)
		
		
		game_folders[idx] = dir_name
		game_folder_paths[idx] = dir
		idx = idx + 1
	end
	
	--debug print
	-- for i = 0, idx - 1 do 
		-- --Msg(" ")
		-- --Msg(game_folder_paths[i])
		-- Msg(game_folders[i])
	-- end
	Msg("Scan completed.")
end


function SeparateFolderAndFileName (name)
	local folder_name, file_name = name:match("([^,]+)-([^,]+)")
	return folder_name, file_name
end


function MoveSoundToGameProject(sound_name)

	
end

function MoveSounds()
	Msg("\n===============")
	Msg("Moving Sounds...\n")
	--za svaki zvuk
	for i in pairs(sounds_to_move) do
		folder,filename = SeparateFolderAndFileName(sounds_to_move[i])
		
		if folder == "game" then
			--move it to interface folder
			Msg("__________________________________")
			Msg("For:           "..sounds_to_move[i])
			Msg("Create:      "..filename.."\nIn path:     P:data\\interface\\_sounds\\\n")
		else
			if folder == last_export_folder then --ako je isti folder kao prethodni
				--prebaci u isti folder kao prethodni
				Msg("__________________________________")
				Msg("For:           "..sounds_to_move[i])
				Msg("Create:      "..filename.."\nIn path:     "..last_export_folder_path)
				Msg("")
			else										 --ako treba da traži folder
				local folder_found = false
				--nadji folder
					
				--provera dal je _ho folder ili _ho_second ili _ho_nesto
				is_ho = string.find(folder,'_ho')
				if is_ho ~= nil then
					ho_folder_name = string.sub(folder, is_ho, -1)
					--Msg(ho_folder_name.."\n")
					folder = string.sub(folder,0,-(string.len(ho_folder_name)+1)) --oduzmi ho deo iz folder imena
					ho_folder_name = "\\"..string.sub(ho_folder_name,2,-1) --ovo se koristi posle sa prefiskom \
					--Msg(folder)
				end
				
				
				--moveit normalno i stavi taj folder kao poslednji...
				for j in pairs(game_folders) do
					if game_folders[j] == folder then
						Msg("__________________________________")
						Msg("For:           "..sounds_to_move[i])
						Msg("Create:      "..filename.."\nIn path:     "..game_folder_paths[j]..ho_folder_name.."\\_sounds\\")
						last_export_folder = game_folders[j]
						last_export_folder_path = game_folder_paths[j]..ho_folder_name.."\\_sounds\\"
						folder_found = true
						break
					end
				end
				Msg(" ")				
					
					
				--exception kad ne nadje folder
				if folder_found == false then
					--proveri da li samo ne postoji _sounds folder i napravi ga ako je to slucaj
				

					--izbaci gresku ako uopste ne postoji folder
					Msg("ERROR***********************************************")
					Msg("For:           "..sounds_to_move[i])
					Msg(folder.." folder does not exist!\nCheck for typos.")
					Msg("*********************************************************\n")
				end
					
			end
		end		
		
		
		
		

	end
end



function Main()
	ScanSoundsToMove()
	ScanFoldersInGameProjectFolder()
	MoveSounds()
end


--upotreba
Main()
