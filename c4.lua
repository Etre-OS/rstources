-- R² c⁴ Parser Engine
local c4 = {}

function c4.parse(config_string)
    local state = {}
    local current_block = nil

    -- Iterate through the string line by line
    for line in config_string:gmatch("[^\r\n]+") do
        -- Trim leading and trailing whitespace
        line = line:match("^%s*(.-)%s*$")
        
        -- Ignore empty lines and comments (starting with #)
        if line ~= "" and line:sub(1, 1) ~= "#" then
            
            -- Check if line opens a new block: "blockname {"
            local block_start = line:match("^(%w+)%s*{")
            if block_start then
                current_block = block_start
                state[current_block] = {} -- Initialize the block in our state table
            
            -- Check if line closes a block: "}"
            elseif line == "}" then
                current_block = nil
            
            -- If we are inside a block, parse key = value
            elseif current_block then
                local key, val = line:match("^(%w+)%s*=%s*(.+)")
                
                if key and val then
                    -- 1. Parse Booleans
                    if val == "true" then 
                        val = true
                    elseif val == "false" then 
                        val = false
                    
                    -- 2. Parse Numbers
                    elseif tonumber(val) then 
                        val = tonumber(val)
                    
                    -- 3. Parse RGB Colors: rgb(r, g, b)
                    elseif val:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)") then
                        local r, g, b = val:match("rgb%((%d+),%s*(%d+),%s*(%d+)%)")
                        val = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                    
                    -- 4. Parse Strings (Strip the quotes)
                    else 
                        val = val:gsub('^"(.*)"$', '%1') 
                    end
                    
                    -- Assign to the state tree
                    state[current_block][key] = val
                end
            end
        end
    end
    
    return state
end

return c4
