--todo --proveriti koliko ima itema, ne raditi mozda ako vec ima vise od jednog tejka
reaper.Main_OnCommand(41999,0) --Item: Render items to new take
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELECTFIRSTTAKEOFITEMS"),0) --Xenakios/SWS: Select first take in selected items
reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_TAKESRANDCOLS"),0) --one random custom take color
