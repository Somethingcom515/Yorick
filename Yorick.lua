Yorick.config = SMODS.current_mod.config

local files = {
    "ui",
    "hooks",
    "utils",
}
for i, v in ipairs(files) do    
    local f, err = SMODS.load_file(v..".lua")
    if f then f()
    else error(err) end
end

SMODS.Atlas {
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
}:register()

function Yorick.recursive_extra(table_return_table, index)
    if #table_return_table == 0 then return nil elseif #table_return_table == 1 then return table_return_table[1] end
    if not index then index = 1 end
    local ret = table_return_table[index]
    if index <= #table_return_table then
        local function getDeepest(tbl)
            tbl = tbl or {}
            while tbl.extra do
                tbl = tbl.extra
            end
            return tbl
        end
        local prev = getDeepest(ret)
        prev.extra = Yorick.recursive_extra(table_return_table, index + 1)
    end
    return ret
end