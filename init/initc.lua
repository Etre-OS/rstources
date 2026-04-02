local initc = {}
local function get_default_state()
    return {
        window = { width = 314, height = 180, name = "R² UI", sidebar = false },
        decoration = { rounding = 6, opacity = 0.2, glass_opacity = 0.15 },
        colors = { background = Color3.fromRGB(24,24,24), text = Color3.fromRGB(255,255,255), border = Color3.fromRGB(89,89,89) }
    }
end

local function parse_c4(cfg)
    local state, block = {}, nil
    for line in cfg:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and line:sub(1, 1) ~= "#" then
            local bStart = line:match("^(%w+)%s*{")
            if bStart then block = bStart; state[block] = {} 
            elseif line == "}" then block = nil
            elseif block then
                local k, v = line:match("^(%w+)%s*=%s*(.+)")
                if k and v then
                    if v == "true" then v = true elseif v == "false" then v = false elseif tonumber(v) then v = tonumber(v)
                    elseif v:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)") then
                        local r, g, b = v:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)"); v = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                    else v = v:gsub('^"(.*)"$', '%1') end
                    state[block][k] = v
                end
            end
        end
    end
    return state
end

function initc.boot(Rnotifd)
    if isfile and isfile("r2.c4") then
        Rnotifd.push("initc", "Parsing r2.c4 environment...", 2)
        local s, state = pcall(parse_c4, readfile("r2.c4"))
        if s and state and state.window then return state end
    end
    Rnotifd.push("initx", "Using default fallback state.", 3)
    return get_default_state()
end
return initc
