-- initc.lua: The Config Parser
local HttpService = game:GetService("HttpService")

return function()
    local state = {
        UI = { width = 314, height = 180, name = "localfunc.ui", expanded = false, sidebar = false },
        Position = { x = 236, y = 94 },
        Colors = { bg_r = 255, bg_g = 255, bg_b = 255 },
        Features = {}
    }

    local configName = "R2_Config"

    -- 1. Try modern R² config
    if isfile(configName .. ".initc") then
        local rawData = readfile(configName .. ".initc")
        -- (Insert your string parsing logic here for the iniC syntax we discussed)
        -- For now, assume it modifies the `state` table.
        return state
    end

    -- 2. Try legacy Balkr config
    if isfile(configName .. ".json") then
        local rawJson = readfile(configName .. ".json")
        local parsed = HttpService:JSONDecode(rawJson)
        
        -- Map legacy features to the new state
        for key, val in pairs(parsed) do
            state.Features[key] = val
        end
        
        state.UI.name = "R² (Legacy Config)"
        return state
    end

    -- 3. No config found at all, but no errors. Return default fresh state.
    return state
end
