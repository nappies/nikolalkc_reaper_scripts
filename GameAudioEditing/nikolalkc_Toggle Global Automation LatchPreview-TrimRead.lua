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

--TOGGLE GLOBAL AUTOMATION OVERRIDE FROM LATCH-PREVIEW TO TRIM-READ AND VICEVERSA
--0 - Trim Read
--1 - Read
--2 - Touch
--3 - Write
--4 - Latch
--5 - Latch Preview

--reaper.ShowConsoleMsg("")
auto_mode = reaper.GetGlobalAutomationOverride()

--reaper.ShowConsoleMsg("\n"..auto_mode)

if auto_mode == 0 then
  reaper.SetGlobalAutomationOverride(5)
else
  reaper.SetGlobalAutomationOverride(0)
end
