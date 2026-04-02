-- R² UI Builder (post/builder.lua)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Builder = {}

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
    local win = State.window or {width = 400, height = 250, name = "R² UI", sidebar = false}
    local col = State.colors or {background = Color3.new(0.1,0.1,0.1), text = Color3.new(1,1,1), border = Color3.new(0.3,0.3,0.3)}
    local dec = State.decoration or {rounding = 6, opacity = 0.2, glass_opacity = 0.15}

    local targetParent = pcall(function() return gethui() end) and gethui() or (pcall(function() return CoreGui end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui"))
    local ScreenGui = Instance.new("ScreenGui", targetParent)
    ScreenGui.Name = "R2_Interface"

    -- [[ 1. BASE FRAMES & TRANSPARENCY ]]
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = col.background
    MainFrame.BackgroundTransparency = dec.opacity -- Applies c⁴ transparency
    MainFrame.Size = UDim2.new(0, win.width, 0, win.height)
    MainFrame.Position = UDim2.new(0.5, -(win.width/2), 0.5, -(win.height/2))
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, dec.rounding)
    local ms = Instance.new("UIStroke", MainFrame); ms.Color = col.border; ms.Thickness = 1

    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.BackgroundColor3 = col.background
    HeaderFrame.BackgroundTransparency = dec.opacity
    HeaderFrame.BorderSizePixel = 0
    Instance.new("UICorner", HeaderFrame).CornerRadius = UDim.new(0, dec.rounding)
    local hs = Instance.new("UIStroke", HeaderFrame); hs.Color = col.border; hs.Thickness = 1

    local AccentFrame = Instance.new("Frame", MainFrame)
    AccentFrame.BackgroundColor3 = col.background
    AccentFrame.BackgroundTransparency = dec.opacity
    AccentFrame.BorderSizePixel = 0
    Instance.new("UICorner", AccentFrame).CornerRadius = UDim.new(0, dec.rounding)
    local as = Instance.new("UIStroke", AccentFrame); as.Color = col.border; as.Thickness = 1

    local TitleLabel = Instance.new("TextLabel", HeaderFrame)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = win.name
    TitleLabel.TextColor3 = col.text
    TitleLabel.TextSize = 14
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TitleLabel.ZIndex = 3

    -- [[ 2. AERO TEXTURES ]]
    local function applyGlass(parent, url, fname)
        if not url then return end
        local img = Instance.new("ImageLabel", parent)
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Image = fetchAsset(url, fname)
        img.ScaleType = Enum.ScaleType.Stretch
        img.ImageTransparency = dec.glass_opacity -- Applies c⁴ glass opacity
        img.ZIndex = 1
        Instance.new("UICorner", img).CornerRadius = UDim.new(0, dec.rounding)
    end

    applyGlass(MainFrame, dec.texture_main, "win7_main.png")
    applyGlass(HeaderFrame, dec.texture_header, "win7_head.png")
    applyGlass(AccentFrame, dec.texture_accent, "win7_acc.png")

    -- [[ 3. CONTENT AREA (The Canvas) ]]
    -- We put a ScrollingFrame inside MainFrame to hold all the UI elements
    local ContentContainer = Instance.new("ScrollingFrame", MainFrame)
    ContentContainer.Size = UDim2.new(1, -20, 1, -20)
    ContentContainer.Position = UDim2.new(0, 10, 0, 10)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = col.border
    ContentContainer.ZIndex = 4

    local UIListLayout = Instance.new("UIListLayout", ContentContainer)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)

    -- Auto-resize canvas
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end)

    -- [[ 4. DRAGGING LOGIC ]]
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

    -- [[ 5. LAYOUT MANAGER (WM Morphing) ]]
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
    applyLayout(win.sidebar, false)

    -- [[ 6. COMPONENT API (Tabs, Buttons, Toggles) ]]
    local GUI_API = {}
    local ActiveTab = nil

    function GUI_API:CreateTab(tabName)
        local TabFrame = Instance.new("Frame", ContentContainer)
        TabFrame.Name = tabName
        TabFrame.Size = UDim2.new(1, 0, 0, 0) -- Height is determined by children
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = (ActiveTab == nil) -- First tab is visible by default
        
        local TabLayout = Instance.new("UIListLayout", TabFrame)
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 4)
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrame.Size = UDim2.new(1, 0, 0, TabLayout.AbsoluteContentSize.Y)
        end)

        if not ActiveTab then ActiveTab = TabFrame end

        local TabAPI = {}

        function TabAPI:Show()
            if ActiveTab then ActiveTab.Visible = false end
            TabFrame.Visible = true
            ActiveTab = TabFrame
        end

        function TabAPI:CreateLabel(text)
            local lbl = Instance.new("TextLabel", TabFrame)
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.Font = Enum.Font.Code
            lbl.TextColor3 = col.text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        function TabAPI:CreateButton(text, callback)
            local btn = Instance.new("TextButton", TabFrame)
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = col.background
            btn.BackgroundTransparency = dec.opacity
            btn.Text = text
            btn.Font = Enum.Font.Code
            btn.TextColor3 = col.text
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local bs = Instance.new("UIStroke", btn); bs.Color = col.border; bs.Thickness = 1

            btn.MouseButton1Click:Connect(function()
                -- Click animation
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = dec.opacity}):Play()
                pcall(callback)
            end)
        end

        function TabAPI:CreateToggle(text, default, callback)
            local state = default or false
            local tog = Instance.new("TextButton", TabFrame)
            tog.Size = UDim2.new(1, 0, 0, 28)
            tog.BackgroundColor3 = col.background
            tog.BackgroundTransparency = dec.opacity
            tog.Text = text .. " : " .. tostring(state)
            tog.Font = Enum.Font.Code
            tog.TextColor3 = state and Color3.new(0, 1, 0.5) or col.text
            tog.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding", tog).PaddingLeft = UDim.new(0, 8)
            Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 4)
            local ts = Instance.new("UIStroke", tog); ts.Color = col.border; ts.Thickness = 1

            tog.MouseButton1Click:Connect(function()
                state = not state
                tog.Text = text .. " : " .. tostring(state)
                TweenService:Create(tog, TweenInfo.new(0.2), {TextColor3 = state and Color3.new(0, 1, 0.5) or col.text}):Play()
                pcall(callback, state)
            end)
        end

        return TabAPI
    end

    GUI_API.ToggleLayout = function() applyLayout(not isSidebar, true) end
    return GUI_API
end

return Builder
