--[[
    R² UI Builder (post/builder.lua)
    Maps c⁴ State variables dynamically to the UI instances.
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Builder = {}

function Builder.render(State, Rnotifd)
    Rnotifd.push("Builder", "Mapping c⁴ variables to UI...", 2)

    -- 1. Safely extract state with fallbacks (in case of total failure)
    local window = State.window or { width = 314, height = 180, name = "R² fallback" }
    local colors = State.colors or { 
        background = Color3.fromRGB(255, 255, 255), 
        text = Color3.fromRGB(0, 0, 0),
        border = Color3.fromRGB(200, 200, 200)
    }
    local decor = State.decoration or { rounding = 6 }

    -- 2. Resolve target parent (stealth injection)
    local targetParent
    if type(gethui) == "function" then
        targetParent = gethui()
    else
        local success, core = pcall(function() return CoreGui end)
        targetParent = success and core or Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- 3. Build the Hierarchy
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "R2_Interface"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetParent

    -- MAIN WINDOW FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "R2_Main"
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = colors.background
    -- Dynamically apply c⁴ width and height
    MainFrame.Size = UDim2.new(0, window.width, 0, window.height)
    MainFrame.Position = UDim2.new(0, 258, 0, 88) -- We'll add dragging logic here later
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, decor.rounding) -- Apply c⁴ rounding
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = colors.border -- Apply c⁴ border color
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- HEADER / TITLE BAR (Floating offset design from Localmaze)
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "R2_Header"
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.BackgroundColor3 = colors.background
    HeaderFrame.Size = UDim2.new(0, window.width - 42, 0, 28)
    HeaderFrame.Position = UDim2.new(0, 44, 0, -38)
    HeaderFrame.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, decor.rounding)
    HeaderCorner.Parent = HeaderFrame

    local HeaderStroke = Instance.new("UIStroke")
    HeaderStroke.Color = colors.border
    HeaderStroke.Thickness = 1
    HeaderStroke.Parent = HeaderFrame

    -- TITLE TEXT
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "R2_Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Font = Enum.Font.Code -- Monospace for the Unix aesthetic
    TitleLabel.Text = window.name -- Apply c⁴ window name
    TitleLabel.TextColor3 = colors.text -- Apply c⁴ text color
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = HeaderFrame

    -- DECORATIVE ACCENT BLOCK (Left of the floating header)
    local AccentFrame = Instance.new("Frame")
    AccentFrame.Name = "R2_Accent"
    AccentFrame.BorderSizePixel = 0
    AccentFrame.BackgroundColor3 = colors.background
    AccentFrame.Size = UDim2.new(0, 40, 0, 30)
    AccentFrame.Position = UDim2.new(0, -46, 0, -2)
    AccentFrame.Parent = HeaderFrame

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, decor.rounding)
    AccentCorner.Parent = AccentFrame

    local AccentStroke = Instance.new("UIStroke")
    AccentStroke.Color = colors.border
    AccentStroke.Thickness = 1
    AccentStroke.Parent = AccentFrame

    Rnotifd.push("R² READY", "UI rendered using c⁴ theme constraints.", 3)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        HeaderFrame = HeaderFrame
    }
end

return Builder
