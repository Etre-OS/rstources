-- R² Notification Daemon (Mako-style)
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Safely get a hidden GUI container (fallback to PlayerGui if strictly sandboxed)
local targetParent = pcall(function() return CoreGui end) and CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local NotifContainer = Instance.new("ScreenGui")
NotifContainer.Name = "R2_MakoDaemon"
NotifContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifContainer.Parent = targetParent

local Mako = {}
Mako.ActiveNotifs = {} -- Keeps track of active notifications for Mako-style stacking

-- Default Mako-esque Theme (Minimalist, readable)
Mako.DefaultTheme = {
    bg = Color3.fromRGB(24, 24, 24),     -- Deep monochrome gray
    text = Color3.fromRGB(255, 255, 255),
    border = Color3.fromRGB(89, 89, 89), -- Subtle inactive border
    rounding = 6,                        -- Slight corner rounding
    width = 280,
    font = Enum.Font.Code                -- Monospace for that terminal feel
}

function Mako.send(title, message, duration, customTheme)
    duration = duration or 3
    local theme = customTheme or Mako.DefaultTheme

    -- 1. Create the Notification Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, theme.width, 0, 60)
    frame.Position = UDim2.new(0.5, -(theme.width/2), 0, -80) -- Start hidden above screen
    frame.BackgroundColor3 = theme.bg
    frame.BorderSizePixel = 0
    frame.Parent = NotifContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.rounding)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.border
    stroke.Thickness = 1
    stroke.Parent = frame

    -- 2. Title Label
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = theme.font
    titleLbl.Text = title
    titleLbl.TextColor3 = theme.text
    titleLbl.TextSize = 14
    titleLbl.Font = Enum.Font.GothamBold -- Force bold for title
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = frame

    -- 3. Message Label
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 20)
    msgLbl.Position = UDim2.new(0, 10, 0, 30)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Font = theme.font
    msgLbl.Text = message
    msgLbl.TextColor3 = theme.text
    msgLbl.TextSize = 13
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextTransparency = 0.2 -- Slight dim for body text
    msgLbl.Parent = frame

    -- 4. Calculate Stacking Position
    local stackIndex = #Mako.ActiveNotifs
    table.insert(Mako.ActiveNotifs, frame)
    local targetY = 20 + (stackIndex * 70) -- 20px padding from top, 70px per notification

    -- 5. Tween In (The Drop)
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -(theme.width/2), 0, targetY)
    })
    tweenIn:Play()

    -- 6. TTL (Time To Live) and Cleanup
    task.delay(duration, function()
        -- Slide back up and fade out
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -(theme.width/2), 0, -80),
            BackgroundTransparency = 1
        })
        
        -- Fade text and stroke
        TweenService:Create(titleLbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(msgLbl, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()

        tweenOut:Play()
        tweenOut.Completed:Wait()
        
        -- Remove from stack and destroy
        table.remove(Mako.ActiveNotifs, table.find(Mako.ActiveNotifs, frame))
        frame:Destroy()

        -- Shift remaining notifications up
        for i, activeFrame in ipairs(Mako.ActiveNotifs) do
            local newY = 20 + ((i - 1) * 70)
            TweenService:Create(activeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -(theme.width/2), 0, newY)
            }):Play()
        end
    end)
end

return Mako
