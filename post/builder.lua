--[[
    R² UI Builder
    Dynamic Rendering Engine with Topbar/Sidebar switching.
--]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- [[ R² Asset Fetcher & Cacher ]]
-- Downloads web images and converts them to executor-safe assets
local function fetchAsset(url, filename)
    -- If the executor doesn't support local assets, return empty
    if not (isfile and writefile and getcustomasset) then 
        return "" 
    end

    local cacheDir = "R2_Assets"
    local filePath = cacheDir .. "/" .. filename

    if not isfolder(cacheDir) then
        makefolder(cacheDir)
    end

    -- Download only if we haven't already cached it
    if not isfile(filePath) then
        local success, imgData = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and imgData then
            writefile(filePath, imgData)
        else
            return "" -- Download failed
        end
    end

    return getcustomasset(filePath)
end

local Builder = {}

function Builder.render(State, Rnotifd)
    Rnotifd.push("Builder", "Constructing dynamic DOM...", 2)

    local window = State.window or { width = 314, height = 180, name = "localfunc.ui", sidebar = false }
    local colors = State.colors or { 
        background = Color3.fromRGB(24, 24, 24), 
        text = Color3.fromRGB(255, 255, 255),
        border = Color3.fromRGB(89, 89, 89)
    }
    local decor = State.decoration or { rounding = 6 }

    local targetParent = pcall(function() return gethui() end) and gethui() or (pcall(function() return CoreGui end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui"))

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "R2_Interface"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetParent

    -- MAIN WINDOW
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "R2_Main"
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = colors.background
    MainFrame.Size = UDim2.new(0, window.width, 0, window.height)
    MainFrame.Position = UDim2.new(0.5, -(window.width/2), 0.5, -(window.height/2))
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, decor.rounding)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = colors.border
    MainStroke.Thickness = 1

    -- DYNAMIC HEADER/SIDEBAR
    local HeaderFrame = Instance.new("Frame")
    HeaderFrame.Name = "R2_Header"
    HeaderFrame.BorderSizePixel = 0
    HeaderFrame.BackgroundColor3 = colors.background
    HeaderFrame.Parent = MainFrame

    Instance.new("UICorner", HeaderFrame).CornerRadius = UDim.new(0, decor.rounding)
    
    local HeaderStroke = Instance.new("UIStroke", HeaderFrame)
    HeaderStroke.Color = colors.border
    HeaderStroke.Thickness = 1

    -- TITLE TEXT
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "R2_Title"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = window.name
    TitleLabel.TextColor3 = colors.text
    TitleLabel.TextSize = 14
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5) -- Anchor center for clean rotation
    TitleLabel.Parent = HeaderFrame

    -- ACCENT BLOCK
    local AccentFrame = Instance.new("Frame")
    AccentFrame.Name = "R2_Accent"
    AccentFrame.BorderSizePixel = 0
    AccentFrame.BackgroundColor3 = colors.background
    AccentFrame.Parent = MainFrame

    Instance.new("UICorner", AccentFrame).CornerRadius = UDim.new(0, decor.rounding)
    
    local AccentStroke = Instance.new("UIStroke", AccentFrame)
    AccentStroke.Color = colors.border
    AccentStroke.Thickness = 1

    -- [[ LAYOUT STATE MANAGER ]]
    local isSidebar = false
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local function applyLayout(forceSidebar, animate)
        isSidebar = forceSidebar

        -- Calculate coordinates based on state
        local headerSize, headerPos
        local accentSize, accentPos
        local textRotation, textSize, textPos

        if isSidebar then
            -- SIDEBAR MODE (Left side, vertical)
            headerSize = UDim2.new(0, 30, 0, window.height - 40)
            headerPos = UDim2.new(0, -40, 0, 40)
            
            accentSize = UDim2.new(0, 30, 0, 30)
            accentPos = UDim2.new(0, -40, 0, 0)
            
            textRotation = -90
            textSize = UDim2.new(0, window.height - 40, 0, 30)
            textPos = UDim2.new(0.5, 0, 0.5, 0)
        else
            -- TOPBAR MODE (Original Localmaze layout)
            headerSize = UDim2.new(0, window.width - 46, 0, 28)
            headerPos = UDim2.new(0, 46, 0, -38)
            
            accentSize = UDim2.new(0, 40, 0, 30)
            accentPos = UDim2.new(0, 0, 0, -40)
            
            textRotation = 0
            textSize = UDim2.new(1, -20, 1, 0)
            textPos = UDim2.new(0.5, 0, 0.5, 0)
        end

        if animate then
            TweenService:Create(HeaderFrame, tweenInfo, {Size = headerSize, Position = headerPos}):Play()
            TweenService:Create(AccentFrame, tweenInfo, {Size = accentSize, Position = accentPos}):Play()
            TweenService:Create(TitleLabel, tweenInfo, {Rotation = textRotation, Size = textSize, Position = textPos}):Play()
        else
            HeaderFrame.Size = headerSize
            HeaderFrame.Position = headerPos
            AccentFrame.Size = accentSize
            AccentFrame.Position = accentPos
            TitleLabel.Rotation = textRotation
            TitleLabel.Size = textSize
            TitleLabel.Position = textPos
        end
    end

    -- Apply initial layout based on c⁴ config (no animation on first load)
    applyLayout(window.sidebar, false)

    Rnotifd.push("R² READY", "UI rendered. Layout state: " .. (window.sidebar and "Sidebar" or "Topbar"), 3)

    -- [[ EXPORTED API ]]
    -- Return the GUI and the layout toggle function so other scripts can bind it to a button
    return {
        Gui = ScreenGui,
        Main = MainFrame,
        toggleLayout = function()
            applyLayout(not isSidebar, true)
        end
    }
end

return Builder
