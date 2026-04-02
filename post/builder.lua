-- R² UI Builder (post/builder.lua)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Builder = {}

-- 1. GitHub Asset Cacher
local function fetchAsset(url, filename)
    if not (isfile and writefile and getcustomasset) then return "" end
    local path = "R2_Assets/" .. filename
    if not isfolder("R2_Assets") then makefolder("R2_Assets") end
    if not isfile(path) then
        local s, data = pcall(function() return game:HttpGet(url) end)
        if s and data then writefile(path, data) else return "" end
    end
    return getcustomasset(path)
end

function Builder.render(State, Rnotifd)
    Rnotifd.push("Builder", "Constructing R² DOM...", 2)

    local win = State.window or {width = 314, height = 180, name = "R²", sidebar = false}
    local col = State.colors or {background = Color3.new(0.1,0.1,0.1), text = Color3.new(1,1,1), border = Color3.new(0.3,0.3,0.3)}
    local dec = State.decoration or {rounding = 6}

    local targetParent = pcall(function() return gethui() end) and gethui() or (pcall(function() return CoreGui end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui"))

    local ScreenGui = Instance.new("ScreenGui", targetParent)
    ScreenGui.Name = "R2_Interface"

    -- Base Window
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = col.background
    MainFrame.Size = UDim2.new(0, win.width, 0, win.height)
    MainFrame.Position = UDim2.new(0.5, -(win.width/2), 0.5, -(win.height/2))
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, dec.rounding)
    local ms = Instance.new("UIStroke", MainFrame); ms.Color = col.border; ms.Thickness = 1

    -- Header & Accent
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.BackgroundColor3 = col.background
    HeaderFrame.BorderSizePixel = 0
    Instance.new("UICorner", HeaderFrame).CornerRadius = UDim.new(0, dec.rounding)
    local hs = Instance.new("UIStroke", HeaderFrame); hs.Color = col.border; hs.Thickness = 1

    local AccentFrame = Instance.new("Frame", MainFrame)
    AccentFrame.BackgroundColor3 = col.background
    AccentFrame.BorderSizePixel = 0
    Instance.new("UICorner", AccentFrame).CornerRadius = UDim.new(0, dec.rounding)
    local as = Instance.new("UIStroke", AccentFrame); as.Color = col.border; as.Thickness = 1

    -- Text
    local TitleLabel = Instance.new("TextLabel", HeaderFrame)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = win.name
    TitleLabel.TextColor3 = col.text
    TitleLabel.TextSize = 14
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TitleLabel.ZIndex = 2 -- Keeps text above glass

    -- 2. Apply Aero Glass
    local function applyGlass(parent, url, fname)
        if not url then return end
        local img = Instance.new("ImageLabel", parent)
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Image = fetchAsset(url, fname)
        img.ScaleType = Enum.ScaleType.Stretch
        img.ImageTransparency = 0.15
        img.ZIndex = 1
        Instance.new("UICorner", img).CornerRadius = UDim.new(0, dec.rounding)
    end

    applyGlass(MainFrame, dec.texture_main, "win7_main.png")
    applyGlass(HeaderFrame, dec.texture_header, "win7_head.png")
    applyGlass(AccentFrame, dec.texture_accent, "win7_acc.png")

    -- 3. Window Manager Layout Logic
    local isSidebar = false
    local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local function applyLayout(forceSidebar, animate)
        isSidebar = forceSidebar
        local hSz, hPos, aSz, aPos, tRot, tSz, tPos

        if isSidebar then
            hSz, hPos = UDim2.new(0, 30, 0, win.height - 40), UDim2.new(0, -40, 0, 40)
            aSz, aPos = UDim2.new(0, 30, 0, 30), UDim2.new(0, -40, 0, 0)
            tRot, tSz, tPos = -90, UDim2.new(0, win.height - 40, 0, 30), UDim2.new(0.5, 0, 0.5, 0)
        else
            hSz, hPos = UDim2.new(0, win.width - 46, 0, 28), UDim2.new(0, 46, 0, -38)
            aSz, aPos = UDim2.new(0, 40, 0, 30), UDim2.new(0, 0, 0, -40)
            tRot, tSz, tPos = 0, UDim2.new(1, -20, 1, 0), UDim2.new(0.5, 0, 0.5, 0)
        end

        if animate then
            TweenService:Create(HeaderFrame, tInfo, {Size = hSz, Position = hPos}):Play()
            TweenService:Create(AccentFrame, tInfo, {Size = aSz, Position = aPos}):Play()
            TweenService:Create(TitleLabel, tInfo, {Rotation = tRot, Size = tSz, Position = tPos}):Play()
        else
            HeaderFrame.Size, HeaderFrame.Position = hSz, hPos
            AccentFrame.Size, AccentFrame.Position = aSz, aPos
            TitleLabel.Rotation, TitleLabel.Size, TitleLabel.Position = tRot, tSz, tPos
        end
    end

    -- 4. Dragging Logic
    local function makeDraggable(gui, handle)
        local dragging, dragStart, startPos = false, nil, nil
        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging, dragStart, startPos = true, inp.Position, gui.Position
                inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - dragStart
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    makeDraggable(MainFrame, HeaderFrame)
    makeDraggable(MainFrame, AccentFrame)

    applyLayout(win.sidebar, false)
    Rnotifd.push("R² SECURE", "Engine running.", 3)

    return {
        Gui = ScreenGui,
        Main = MainFrame,
        toggleLayout = function() applyLayout(not isSidebar, true) end
    }
end

return Builder
