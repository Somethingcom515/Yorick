Yorick = SMODS.current_mod
Yorick.blacklist = {}

to_big = to_big or function(x) return x end
to_number = to_number or function(x) return x end

local files = {
    'ui',
    'hooks',
    'utils',
}

for _, v in ipairs(files) do    
    local f, err = SMODS.load_file(v..'.lua')
    if f then f()
    else error(err) end
end