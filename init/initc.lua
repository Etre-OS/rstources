--[[
    R² initc
    The primary init system & c⁴ parser.
--]]

local HttpService = game:GetService("HttpService")

local initc = {}

-- [[ The c⁴ Parsing Engine ]]
local function parse_c4(config_string)
    local state = {}
    local current_block = nil

    for line in config_string:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- Trim whitespace
        
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

-- [[ The Fallback Engine (initx equivalent) ]]
local function get_default_state()
    return {
        window = { width = 314, height = 180, name = "localfunc.ui", sidebar = false },
        decoration = { rounding = 6, blur = false, blur_passes = 0, drop_shadow = false },
        colors = { 
            background = Color3.fromRGB(24, 24, 24), 
            text = Color3.fromRGB(255, 255, 255), 
            border = Color3.fromRGB(89, 89, 89) 
        },
        features = {}
    }
end

-- [[ The Boot Sequence ]]
-- Rnotifd is passed in from the bootloader so initc can broadcast its status
function initc.boot(Rnotifd)
    -- 1. Try loading native R² c⁴ config
    if isfile and isfile("r2.c4") then
        Rnotifd.push("initc", "Parsing r2.c4 environment...", 2)
        local raw_c4 = readfile("r2.c4")
        
        local success, state = pcall(parse_c4, raw_c4)
        if success and state and state.window then
            Rnotifd.push("initc", "c⁴ parsed successfully.", 2)
            return state
        else
            Rnotifd.push("initc ERROR", "Syntax error in r2.c4. Checking fallbacks.", 4)
        end
    end

    -- 2. Try loading legacy Balkr JSON
    if isfile and isfile("LegitCfg.json") then
        Rnotifd.push("initc", "Legacy Balkr config detected. Porting...", 3)
        local raw_json = readfile("LegitCfg.json")
        
        local success, parsed_json = pcall(function()
            return HttpService:JSONDecode(raw_json)
        end)

        if success and type(parsed_json) == "table" then
            local state = get_default_state()
            state.window.name = "R² (Legacy Mode)"
            -- Dump old JSON flags into the new features block
            for k, v in pairs(parsed_json) do
                state.features[k] = v
            end
            return state
        end
    end

    -- 3. Total Fallback (initx)
    Rnotifd.push("initx", "No configuration found. Loading defaults.", 3)
    return get_default_state()
end

return initc
