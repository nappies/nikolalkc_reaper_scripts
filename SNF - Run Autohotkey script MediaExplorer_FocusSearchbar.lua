    --get script path
    local info = debug.getinfo(1).source:match("@(.*)") 
    ofni = string.reverse(info)
    idx = string.find(ofni, "\\" )
    htap = string.sub(ofni, idx, -1)
    path = string.reverse(htap)
    --Msg(path);
    
    batch_path = [["]]..path..[[MediaExplorer_FocusSearch.ahk"]]
    io.popen(batch_path)
