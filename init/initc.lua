-- R² Init System & c⁴ Parser (init/initc.lua)
local initc = {}

local function get_default_state()
    return {
        window = { width = 314, height = 180, name = "R² (Fallback)", sidebar = false },
        decoration = { rounding = 6 },
        colors = { background = Color3.fromRGB(24,24,24), text = Color3.fromRGB(255,255,255), border = Color3.fromRGB(89,89,89) }
    }
end

local function parse_c4(config_string)
    local state = {}
    local current_block = nil

    for line in config_string:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and line:sub(1, 1) ~= "#" then
            local block_start = line:match("^(%w+)%s*{")
            if block_start then
                current_block = block_start
                state[current_block] = {} 
            elseif line == "}" then
                current_block = nil
            elseif current_block then
                local key, val = line:match("^(%w+)%s*=%s*(.+)")
                if key and val then
                    if val == "true" then val = true
                    elseif val == "false" then val = false
                    elseif tonumber(val) then val = tonumber(val)
                    elseif val:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)") then
                        local r, g, b = val:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
                        val = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                    else 
                        val = val:gsub('^"(.*)"$', '%1') 
                    end
                    state[current_block][key] = val
                end
            end
        end
    end
    return state
end

function initc.boot(Rnotifd)
    if isfile and isfile("r2.c4") then
        Rnotifd.push("initc", "Parsing r2.c4 environment...", 2)
        local success, state = pcall(parse_c4, readfile("r2.c4"))
        if success and state and state.window then return state end
    end
    Rnotifd.push("initx", "No valid c⁴ config. Using defaults.", 3)
    return get_default_state()
end

return initc
