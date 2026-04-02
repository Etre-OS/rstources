local CoreGui, Players, TweenService, UserInputService, RunService = game:GetService("CoreGui"), game:GetService("Players"), game:GetService("TweenService"), game:GetService("UserInputService"), game:GetService("RunService")
local Compositor = {}

local function fetchAsset(url, fname)
    if not (isfile and writefile and getcustomasset) then return "" end
    local path = "R2_Assets/" .. fname
    if not isfolder("R2_Assets") then makefolder("R2_Assets") end
    if not isfile(path) then local s, d = pcall(function() return game:HttpGet(url) end); if s and d then writefile(path, d) else return "" end end
    return getcustomasset(path)
end

function Compositor.build(State, Rnotifd)
    local win = State.window or {width=314, height=180, name="R²", sidebar=false}
    local col = State.colors or {background=Color3.new(0.1,0.1,0.1), text=Color3.new(1,1,1), border=Color3.new(0.3,0.3,0.3)}
    local dec = State.decoration or {rounding=6, opacity=0.2, glass_opacity=0.15}

    local targetParent = pcall(function() return gethui() end) and gethui() or (pcall(function() return CoreGui end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui"))
    local ScreenGui = Instance.new("ScreenGui", targetParent)
    ScreenGui.Name = "R2_Compositor"

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.BorderSizePixel = col.background, dec.opacity, 0
    MainFrame.Size, MainFrame.Position = UDim2.new(0, win.width, 0, win.height), UDim2.new(0.5, -(win.width/2), 0.5, -(win.height/2))
    MainFrame.Active = true -- Prevent input bleed
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, dec.rounding)
    local ms = Instance.new("UIStroke", MainFrame); ms.Color = col.border; ms.Thickness = 1

    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.BackgroundColor3, HeaderFrame.BackgroundTransparency, HeaderFrame.BorderSizePixel = col.background, dec.opacity, 0
    Instance.new("UICorner", HeaderFrame).CornerRadius = UDim.new(0, dec.rounding)
    local hs = Instance.new("UIStroke", HeaderFrame); hs.Color = col.border; hs.Thickness = 1

    local AccentFrame = Instance.new("Frame", MainFrame)
    AccentFrame.BackgroundColor3, AccentFrame.BackgroundTransparency, AccentFrame.BorderSizePixel = col.background, dec.opacity, 0
    Instance.new("UICorner", AccentFrame).CornerRadius = UDim.new(0, dec.rounding)
    local as = Instance.new("UIStroke", AccentFrame); as.Color = col.border; as.Thickness = 1

    local TitleLabel = Instance.new("TextLabel", HeaderFrame)
    TitleLabel.BackgroundTransparency, TitleLabel.Font, TitleLabel.Text, TitleLabel.TextColor3 = 1, Enum.Font.Code, win.name, col.text
    TitleLabel.TextSize, TitleLabel.AnchorPoint, TitleLabel.ZIndex = 14, Vector2.new(0.5, 0.5), 3

    local function applyGlass(parent, url, fname)
        if not url then return end
        local img = Instance.new("ImageLabel", parent)
        img.BackgroundTransparency, img.Size, img.Image, img.ScaleType, img.ImageTransparency, img.ZIndex = 1, UDim2.new(1,0,1,0), fetchAsset(url, fname), Enum.ScaleType.Stretch, dec.glass_opacity, 1
        Instance.new("UICorner", img).CornerRadius = UDim.new(0, dec.rounding)
    end

    applyGlass(MainFrame, dec.texture_main, "win7_main.png")
    applyGlass(HeaderFrame, dec.texture_header, "win7_head.png")
    applyGlass(AccentFrame, dec.texture_accent, "win7_acc.png")

    local ContentContainer = Instance.new("ScrollingFrame", MainFrame)
    ContentContainer.Size, ContentContainer.Position = UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10)
    ContentContainer.BackgroundTransparency, ContentContainer.ScrollBarThickness, ContentContainer.ScrollBarImageColor3, ContentContainer.ZIndex = 1, 2, col.border, 4
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Melatonin Fix
    ContentContainer.ClipsDescendants = true -- Melatonin Fix

    local function makeSmoothDraggable(gui, handle)
        local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
        local targetPos = gui.Position

        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, inp.Position, gui.Position
                inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        handle.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dragInput = inp end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then
                local d = dragInput.Position - dragStart
                targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
            if gui.Position ~= targetPos then gui.Position = gui.Position:Lerp(targetPos, 0.2) end
        end)
    end
    makeSmoothDraggable(MainFrame, HeaderFrame)
    makeSmoothDraggable(MainFrame, AccentFrame)

    local isSidebar, tInfo = false, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
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
            TweenService:Create(HeaderFrame, tInfo, {Size=hSz, Position=hPos}):Play()
            TweenService:Create(AccentFrame, tInfo, {Size=aSz, Position=aPos}):Play()
            TweenService:Create(TitleLabel, tInfo, {Rotation=tRot, Size=tSz, Position=tPos}):Play()
        else
            HeaderFrame.Size, HeaderFrame.Position = hSz, hPos
            AccentFrame.Size, AccentFrame.Position = aSz, aPos
            TitleLabel.Rotation, TitleLabel.Size, TitleLabel.Position = tRot, tSz, tPos
        end
    end
    applyLayout(win.sidebar, false)

    return { Container = ContentContainer, ToggleLayout = function() applyLayout(not isSidebar, true) end }
end
return Compositor
