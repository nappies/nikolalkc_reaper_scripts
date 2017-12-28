--[[
 * ReaScript Name:
 * Description:
 * Instructions:
 * Author: nikolalkc
 * Repository URL: https://github.com/nikolalkc/nikolalkc_reaper_scripts
 * REAPER: 5+
 * Extensions: SWS
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (201x-xx-xx)
	+ Initial Release
--]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end



function Main()
  --proba za pull request iz atoma 3
	--list all directories in folder P:\data and exclude:  .svn _prefabs _resources _savegames _sounds===========================================================================================
	--TODO: za ho posebna logika
	--TODO: za interface posebna logika
	--TODO: za hud posebna logika
	-- prog = [[dir "P:\data\" /b /s /a:d | findstr /v "\_interface"| findstr /v "\.svn"|findstr /v "\_prefabs"| findstr /v "\_resources"| findstr /v "\_savegames"| findstr /v "\_sounds"]]
	-- for dir in io.popen(prog):lines() do
		-- rid = string.reverse(dir)
		-- index1 = string.find(rid, "\\" )
		-- rid_name = string.sub(rid, 0, index1-1)
		-- dir_name = string.reverse(rid_name)
		-- --Msg(dir)
		-- Msg(dir_name)
	-- end

	-- prog2 = [[dir "D:\BouncedSounds\" /a:-d /b]]
	-- for dir in io.popen(prog2):lines() do
		-- Msg(dir)
	-- end

	-- --msg box=================================================================================================================================================================================
	-- ok = reaper.ShowMessageBox( [[Do you want to move rendered sounds to P:\data ?

-- Pressing No will open D:\BouncedSounds.]], [[Rendering Completed]], 3 )
	-- --Msg(ok)



	--open folder with batch script==============================================================================================================================================================
	-- sk = [[ "%appdata%\REAPER\Scripts"]]
	-- prog2 =[[%SystemRoot%\explorer.exe]]
	-- prog2 = prog2..sk
	-- io.popen(prog2)



	--move file and overwrite existing===========================================================================================================================================================
	--move_prog = [[move /y "D:\BouncedSounds\region_01.wav" "D:\BouncedSounds\move\new file.wav"
--pause]]





	-- --run batch script=============================================================================================================================================================================
	-- --get script path
	-- local info = debug.getinfo(1).source:match("@(.*)")
	-- ofni = string.reverse(info)
	-- idx = string.find(ofni, "\\" )
	-- htap = string.sub(ofni, idx, -1)
	-- path = string.reverse(htap)
	-- --Msg(path);


	-- batch_path = [["]]..path..[[Reaper_Move_Sounds.ahk"]]
	-- os.execute (batch_path)






	-- --change character inside string==========================================================================================================================================================
	-- a = "44,000002133"
	-- Msg(a)
	-- a = string.gsub(a, "%:", "-")
	-- Msg(a)



	--PCM SHIT===================================================================================================================================================================================
	-- pcm_str = [[D:\proba.wav]]
	-- pcm = reaper.PCM_Source_CreateFromFile(pcm_str)

	-- reaper.BR_SetTakeSourceFromFile2( take[1], pcm_str, false, true)


--     reaper.CSurf_OnZoom(3, 0) --zumiranje po x i y osi

	-- local last_scene = io.open("last_scene.dat", "w")
	-- last_scene:write("KURČINA.")
	-- last_scene:close()

	-- read_last_scene = io.open("last_scene.dat", "r")
	-- Msg(read_last_scene:read())
	-- read_last_scene:close()



	-- --getting environment variable value with Command line
	-- for sta in io.popen([[echo %HOPA_NAME%]]):lines() do
		-- Msg(sta)
	-- end

	--getting environment variable with lua directly
	-- envv = os.getenv("HOPA_NAME")
	-- Msg(envv)

	--print take source state
	-- item = reaper.GetSelectedMediaItem( 0, 0)
	-- fs = reaper.SNM_CreateFastString("")               -- create a new "fast string"
	-- local STATE =  reaper.SNM_GetSetSourceState(item, -1, fs, false) -- get take1 source
	-- local str = reaper.SNM_GetFastString( fs )
	-- Msg(STATE)
	-- Msg(str)

  item = reaper.GetSelectedMediaItem( 0, 0 )
  local strNeedBig = ""
  retval, strNeedBig = reaper.GetItemStateChunk( item, strNeedBig, false )
  Msg(retval)
  Msg(strNeedBig)





end


--function to print return of program in batch
function os.capture(cmd, raw)
    local handle = assert(io.popen(cmd, 'r'))
    local output = assert(handle:read('*a'))

    handle:close()

    if raw then
        return output
    end

    output = string.gsub(
        string.gsub(
            string.gsub(output, '^%s+', ''),
            '%s+$',
            ''
        ),
        '[\n\r]+',
        ' '
    )

   return output
end

Main()