local TweenService, UserInputService = game:GetService("TweenService"), game:GetService("UserInputService")
local Toolkit = {}

function Toolkit.init(Container, State)
    local col = State.colors or {background=Color3.new(0.1,0.1,0.1), text=Color3.new(1,1,1), border=Color3.new(0.3,0.3,0.3)}
    local dec = State.decoration or {rounding=6, opacity=0.2}
    local GUI_API, ActiveTab = {}, nil

    function GUI_API:CreateTab(tabName)
        local TabFrame = Instance.new("Frame", Container)
        TabFrame.Name, TabFrame.Size, TabFrame.BackgroundTransparency = tabName, UDim2.new(1, 0, 0, 0), 1
        TabFrame.AutomaticSize = Enum.AutomaticSize.Y
        TabFrame.Visible = (ActiveTab == nil)
        
        local TabLayout = Instance.new("UIListLayout", TabFrame)
        TabLayout.SortOrder, TabLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)

        if not ActiveTab then ActiveTab = TabFrame end
        local TabAPI = {}

        function TabAPI:Show() if ActiveTab then ActiveTab.Visible = false end; TabFrame.Visible = true; ActiveTab = TabFrame end

        function TabAPI:CreateLabel(text)
            local lbl = Instance.new("TextLabel", TabFrame)
            lbl.Size, lbl.BackgroundTransparency, lbl.Text, lbl.Font, lbl.TextColor3, lbl.TextXAlignment = UDim2.new(1, 0, 0, 20), 1, text, Enum.Font.Code, col.text, Enum.TextXAlignment.Left
        end

        function TabAPI:CreateButton(text, callback)
            local btn = Instance.new("TextButton", TabFrame)
            btn.Size, btn.BackgroundColor3, btn.BackgroundTransparency, btn.Text, btn.Font, btn.TextColor3 = UDim2.new(1, 0, 0, 28), col.background, dec.opacity, text, Enum.Font.Code, col.text
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            local bs = Instance.new("UIStroke", btn); bs.Color = col.border; bs.Thickness = 1

            -- Mobile fix: Activated works for Mouse AND Touch natively
            btn.Activated:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = dec.opacity}):Play()
                pcall(callback)
            end)
        end

        function TabAPI:CreateToggle(text, default, callback)
            local state = default or false
            local tog = Instance.new("TextButton", TabFrame)
            tog.Size, tog.BackgroundColor3, tog.BackgroundTransparency, tog.Font, tog.TextXAlignment = UDim2.new(1, 0, 0, 28), col.background, dec.opacity, Enum.Font.Code, Enum.TextXAlignment.Left
            tog.Text, tog.TextColor3 = text .. " : " .. tostring(state), state and Color3.new(0, 1, 0.5) or col.text
            Instance.new("UIPadding", tog).PaddingLeft, Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 8), UDim.new(0, 4)
            local ts = Instance.new("UIStroke", tog); ts.Color = col.border; ts.Thickness = 1

            tog.Activated:Connect(function()
                state = not state
                tog.Text = text .. " : " .. tostring(state)
                TweenService:Create(tog, TweenInfo.new(0.2), {TextColor3 = state and Color3.new(0, 1, 0.5) or col.text}):Play()
                pcall(callback, state)
            end)
        end

        function TabAPI:CreateSlider(text, min, max, default, callback)
            local val = default or min
            local sCont = Instance.new("Frame", TabFrame); sCont.Size, sCont.BackgroundTransparency = UDim2.new(1, 0, 0, 40), 1
            local Txt = Instance.new("TextLabel", sCont); Txt.Size, Txt.BackgroundTransparency, Txt.Text, Txt.Font, Txt.TextColor3, Txt.TextXAlignment = UDim2.new(1, 0, 0, 16), 1, text .. " : " .. tostring(val), Enum.Font.Code, col.text, Enum.TextXAlignment.Left
            local Track = Instance.new("TextButton", sCont); Track.Size, Track.Position, Track.BackgroundColor3, Track.BackgroundTransparency, Track.Text = UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 20), col.background, dec.opacity, ""
            Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 4)
            local trks = Instance.new("UIStroke", Track); trks.Color = col.border; trks.Thickness = 1
            local Fill = Instance.new("Frame", Track); Fill.BackgroundColor3, Fill.BackgroundTransparency, Fill.Size = col.text, 0.5, UDim2.new((val - min)/(max - min), 0, 1, 0)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

            local dragging = false
            local function updateSlider(inp)
                local pos = math.clamp((inp.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + ((max - min) * pos))
                Txt.Text = text .. " : " .. tostring(val)
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                pcall(callback, val)
            end

            -- Mobile Touch Support added here
            Track.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true; updateSlider(inp) end end)
            UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then updateSlider(inp) end end)
        end
        return TabAPI
    end
    GUI_API.ToggleLayout = function() Container.Parent.Parent:FindFirstChild("R2_Header").Size = Container.Parent.Parent:FindFirstChild("R2_Header").Size end -- Handled via comp return usually, but included in API stub
    return GUI_API
end
return Toolkit
