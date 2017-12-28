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
function run()
  is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
  if is_new then
    reaper.ShowConsoleMsg(name .. "\nrel: " .. rel .. "\nres: " .. res .. "\nval = " .. val .. "\n")
  end
  reaper.defer(run)
end

function onexit()
  reaper.ShowConsoleMsg("<-----\n")
end

reaper.defer(run)
reaper.atexit(onexit)
