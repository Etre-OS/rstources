-- R² Content Toolkit (win/content.lua)
-- Provides Tabs, Buttons, Toggles, and Sliders

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Toolkit = {}

function Toolkit.init(Container, State)
    local col = State.colors or {background = Color3.new(0.1,0.1,0.1), text = Color3.new(1,1,1), border = Color3.new(0.3,0.3,0.3)}
    local dec = State.decoration or {rounding = 6, opacity = 0.2}

    local GUI_API = {}
    local ActiveTab = nil

    function GUI_API:CreateTab(tabName)
        local TabFrame = Instance.new("Frame", Container)
        TabFrame.Name = tabName
        TabFrame.Size = UDim2.new(1, 0, 0, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = (ActiveTab == nil)
        
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

        function TabAPI:CreateSlider(text, min, max, default, callback)
            local sliderValue = default or min
            local SliderContainer = Instance.new("Frame", TabFrame)
            SliderContainer.Size = UDim2.new(1, 0, 0, 40)
            SliderContainer.BackgroundTransparency = 1

            local TitleLabel = Instance.new("TextLabel", SliderContainer)
            TitleLabel.Size = UDim2.new(1, 0, 0, 16)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = text .. " : " .. tostring(sliderValue)
            TitleLabel.Font = Enum.Font.Code
            TitleLabel.TextColor3 = col.text
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Track = Instance.new("TextButton", SliderContainer)
            Track.Size = UDim2.new(1, 0, 0, 14)
            Track.Position = UDim2.new(0, 0, 0, 20)
            Track.BackgroundColor3 = col.background
            Track.BackgroundTransparency = dec.opacity
            Track.Text = ""
            Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 4)
            local trks = Instance.new("UIStroke", Track); trks.Color = col.border; trks.Thickness = 1

            local Fill = Instance.new("Frame", Track)
            Fill.BackgroundColor3 = col.text
            Fill.BackgroundTransparency = 0.5
            Fill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                sliderValue = math.floor(min + ((max - min) * pos))
                TitleLabel.Text = text .. " : " .. tostring(sliderValue)
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                pcall(callback, sliderValue)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
        end

        return TabAPI
    end

    return GUI_API
end

return Toolkit
