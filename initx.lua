-- initx.lua: The Fallback state
return function()
    -- Absolute bare-minimum defaults
    return {
        UI = {
            width = 314,
            height = 180,
            name = "localfunc.ui (FALLBACK MODE)",
            expanded = true,
            sidebar = false
        },
        Position = { x = 100, y = 100 },
        Colors = { 
            bg_r = 255, bg_g = 255, bg_b = 255,
            text_r = 0, text_g = 0, text_b = 0
        },
        Features = {},
        _isFallback = true
    }
end

