--[[
    R² Vanguard (pre-all/notif.lua)
    Mako-style notification daemon - PATCHED
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Safely resolve GUI Parent (Fixes the Line 4 nil issue on fast injection)
local targetParent
if type(gethui) == "function" then
    targetParent = gethui()
else
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if success and core then
        targetParent = core
    else
        local lp = Players.LocalPlayer
        while not lp do
            task.wait(0.1) -- Safely wait for the game to load the player
            lp = Players.LocalPlayer
        end
        targetParent = lp:WaitForChild("PlayerGui")
    end
end

-- Container for notifications
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "R2_Vanguard"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = targetParent

local Notif = {}
local ActiveNotifications = {}

-- Standard R² Monochrome Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(230, 230, 230),
    Font = Enum.Font.Code,
    Rounding = 4
}

function Notif.push(title, content, duration)
    title = title or "R² SYSTEM"
    content = content or ""
    duration = duration or 3

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 260, 0, 50)
    Frame.Position = UDim2.new(0.5, -130, 0, -60)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Theme.Rounding)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Theme.Font
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Frame

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -20, 0, 20)
    ContentLabel.Position = UDim2.new(0, 10, 0, 25)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Font = Theme.Font
    ContentLabel.Text = content
    ContentLabel.TextColor3 = Theme.Text
    ContentLabel.TextSize = 12
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.Parent = Frame

    -- Stacking Logic
    table.insert(ActiveNotifications, Frame)
    local targetY = 20 + ((#ActiveNotifications - 1) * 60)

    -- Animate In
    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -130, 0, targetY)
    }):Play()

    -- Auto-Cleanup
    task.delay(duration, function()
        local outTween = TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -130, 0, -70),
            BackgroundTransparency = 1
        })
        
        outTween:Play()
        outTween.Completed:Wait()
        
        table.remove(ActiveNotifications, table.find(ActiveNotifications, Frame))
        Frame:Destroy()

        -- Shift others up
        for i, otherFrame in ipairs(ActiveNotifications) do
            TweenService:Create(otherFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(0.5, -130, 0, 20 + ((i - 1) * 60))
            }):Play()
        end
    end)
end

return Notif
