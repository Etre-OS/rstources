-- Inside win/comp.lua, update your service list at the top:
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- Added for smooth dragging

-- ... [Keep the fetchAsset function and setup] ...

    -- [[ 1. BASE FRAMES & INPUT TRAPPING ]]
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = col.background
    MainFrame.BackgroundTransparency = dec.opacity
    MainFrame.Size = UDim2.new(0, win.width, 0, win.height)
    MainFrame.Position = UDim2.new(0.5, -(win.width/2), 0.5, -(win.height/2))
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true -- MELATONIN FIX: Blocks clicks from bleeding into the game
    MainFrame.Interactable = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, dec.rounding)
    local ms = Instance.new("UIStroke", MainFrame); ms.Color = col.border; ms.Thickness = 1

-- ... [Keep the Header, Accent, and Glass texture logic] ...

    -- [[ 2. SMOOTH DRAGGING LOGIC ]]
    local function makeSmoothDraggable(gui, handle)
        local dragging = false
        local dragInput, dragStart, startPos
        local targetPos = gui.Position
        local smoothSpeed = 0.15 -- Adjust this for more/less drag weight

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        -- The Melatonin Glide: RenderStepped ensures 144hz smoothness
        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then
                local delta = dragInput.Position - dragStart
                targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
            -- Interpolate towards the target position
            if gui.Position ~= targetPos then
                gui.Position = gui.Position:Lerp(targetPos, smoothSpeed)
            end
        end)
    end

    makeSmoothDraggable(MainFrame, HeaderFrame)
    makeSmoothDraggable(MainFrame, AccentFrame)

-- ... [Keep the Layout Manager (applyLayout) and return block] ...

    -- Layout Manager
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

    -- Export API for content.lua and user scripts
    return {
        Container = ContentContainer,
        ToggleLayout = function() applyLayout(not isSidebar, true) end
    }
end

return Compositor
