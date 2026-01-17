--[[
    miexecutador UI Library (standalone)
    - Sin dependencias externas
    - Tema rojo profesional
    - Tabs, botones, toggles y sliders simples
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Text = Color3.fromRGB(245, 245, 245),
    Background = Color3.fromRGB(18, 18, 20),
    Topbar = Color3.fromRGB(24, 24, 28),
    Stroke = Color3.fromRGB(55, 55, 60),
    Accent = Color3.fromRGB(220, 50, 50),
    Accent2 = Color3.fromRGB(235, 70, 70),
    Element = Color3.fromRGB(28, 28, 32),
    ElementHover = Color3.fromRGB(38, 38, 42),
    Input = Color3.fromRGB(30, 30, 35),
}

local function roundify(obj, r)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, r)
    uic.Parent = obj
    return uic
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput
    local startPos
    local startInputPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            startInputPos = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local Library = {}
Library.Theme = Theme

function Library:CreateWindow(opts)
    opts = opts or {}
    local name = opts.Name or "miexecutador"

    local gui = Instance.new("ScreenGui")
    gui.Name = "miexecutadorUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 480, 0, 360)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Theme.Background
    main.Parent = gui
    roundify(main, 10)
    stroke(main, Theme.Stroke, 1)

    -- Scale animation for opening/closing
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main
    uiScale.Scale = 0.94
    TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 36)
    topbar.BackgroundColor3 = Theme.Topbar
    topbar.Parent = main
    roundify(topbar, 10)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.Font = Enum.Font.GothamSemibold
    title.Text = name
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Size = UDim2.new(0, 36, 0, 24)
    close.Position = UDim2.new(1, -40, 0.5, -12)
    close.BackgroundColor3 = Theme.Accent
    close.Text = "X"
    close.TextColor3 = Theme.Text
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = topbar
    roundify(close, 6)

    -- Close hover animation
    close.MouseEnter:Connect(function()
        TweenService:Create(close, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent2}):Play()
    end)
    close.MouseLeave:Connect(function()
        TweenService:Create(close, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
    end)

    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(0, 130, 1, -44)
    tabBar.Position = UDim2.new(0, 8, 0, 44)
    tabBar.BackgroundTransparency = 0.2
    tabBar.BackgroundColor3 = Theme.Element
    tabBar.Parent = main
    roundify(tabBar, 8)
    stroke(tabBar, Theme.Stroke, 1, 0.2)

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 6)
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.VerticalAlignment = Enum.VerticalAlignment.Begin
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = tabBar

    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.Size = UDim2.new(1, -150, 1, -52)
    pages.Position = UDim2.new(0, 146, 0, 44)
    pages.BackgroundTransparency = 1
    pages.Parent = main

    local currentPage

    -- Launcher button (shown when window closes)
    local launcher = Instance.new("TextButton")
    launcher.Name = "Launcher"
    launcher.Size = UDim2.new(0, 40, 0, 40)
    launcher.Position = UDim2.new(0, 16, 1, -56)
    launcher.AnchorPoint = Vector2.new(0, 1)
    launcher.BackgroundColor3 = Theme.Accent
    launcher.Text = "≡"
    launcher.TextColor3 = Theme.Text
    launcher.Font = Enum.Font.GothamBold
    launcher.TextSize = 20
    launcher.AutoButtonColor = false
    launcher.Visible = false
    launcher.Parent = gui
    roundify(launcher, 20)
    stroke(launcher, Theme.Stroke, 1, 0.2)

    makeDraggable(main, topbar)

    local Window = {}

    function Window:Open()
        main.Visible = true
        launcher.Visible = false
        uiScale.Scale = 0.94
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end

    function Window:Close()
        TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.94}):Play()
        task.delay(0.16, function()
            main.Visible = false
            launcher.Visible = true
        end)
    end

    close.MouseButton1Click:Connect(function()
        Window:Close()
    end)

    launcher.MouseEnter:Connect(function()
        TweenService:Create(launcher, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent2}):Play()
    end)
    launcher.MouseLeave:Connect(function()
        TweenService:Create(launcher, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    launcher.MouseButton1Click:Connect(function()
        Window:Open()
    end)

    function Window:CreateTab(tabName)
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.new(1, -12, 0, 32)
        btn.BackgroundColor3 = Theme.Element
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Text = tabName
        btn.AutoButtonColor = false
        btn.Parent = tabBar
        roundify(btn, 6)
        stroke(btn, Theme.Stroke, 1, 0.3)

        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "Page"
        page.Visible = false
        page.Active = true
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 6
        page.ScrollBarImageColor3 = Theme.Stroke
        page.Parent = pages

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.PaddingTop = UDim.new(0, 6)
        padding.Parent = page

        local selected = false

        local function setSelected(val)
            selected = val
            local targetColor = selected and Theme.Accent or Theme.Element
            TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
        end

        local function select()
            if currentPage then
                currentPage.page.Visible = false
                TweenService:Create(currentPage.button, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Element}):Play()
                if currentPage.page then
                    currentPage.page.Position = UDim2.new(0, 0, 0, 0)
                end
            end
            currentPage = {page = page, button = btn}
            page.Visible = true
            page.Position = UDim2.new(0, 16, 0, 6)
            TweenService:Create(page, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            setSelected(true)
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end

        btn.MouseButton1Click:Connect(select)
        btn.MouseEnter:Connect(function()
            if not selected then
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.ElementHover}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if not selected then
                TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Element}):Play()
            end
        end)
        if not currentPage then select() end

        local Tab = {}

        local function makeCard(height)
            local f = Instance.new("Frame")
            f.BackgroundColor3 = Theme.Element
            f.Size = UDim2.new(1, -4, 0, height)
            f.Parent = page
            roundify(f, 8)
            stroke(f, Theme.Stroke, 1, 0.2)
            return f
        end

        function Tab:CreateSection(titleText)
            local card = makeCard(34)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = titleText
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            return lbl
        end

        function Tab:CreateLabel(text)
            local card = makeCard(44)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Font = Enum.Font.Gotham
            lbl.TextWrapped = true
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.Parent = card
            return lbl
        end

        function Tab:CreateButton(params)
            params = params or {}
            local text = params.Name or "Button"
            local callback = params.Callback or function() end
            local card = makeCard(44)

            local btn = Instance.new("TextButton")
            btn.Name = "Button"
            btn.Size = UDim2.new(1, -16, 1, -12)
            btn.Position = UDim2.new(0, 8, 0, 6)
            btn.BackgroundColor3 = Theme.Accent
            btn.Text = text
            btn.TextColor3 = Theme.Text
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamBold
            btn.AutoButtonColor = false
            btn.Parent = card
            roundify(btn, 6)

            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent2}):Play()
                task.delay(0.15, function()
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
                end)
                callback()
            end)

            return {
                SetText = function(_, t)
                    btn.Text = t
                end,
                Click = function()
                    callback()
                end,
            }
        end

        function Tab:CreateToggle(params)
            params = params or {}
            local text = params.Name or "Toggle"
            local state = params.CurrentValue or false
            local callback = params.Callback or function() end

            local card = makeCard(46)

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card

            local switch = Instance.new("TextButton")
            switch.Size = UDim2.new(0, 54, 0, 22)
            switch.Position = UDim2.new(1, -64, 0.5, -11)
            switch.BackgroundColor3 = Theme.ElementHover
            switch.Text = ""
            switch.AutoButtonColor = false
            switch.Parent = card
            roundify(switch, 11)
            stroke(switch, Theme.Stroke, 1, 0.25)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            knob.BackgroundColor3 = state and Theme.Accent or Theme.Stroke
            knob.Parent = switch
            roundify(knob, 9)

            local function set(val)
                state = val
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = state and Theme.Accent or Theme.Stroke
                }):Play()
                callback(state)
            end

            switch.MouseButton1Click:Connect(function()
                set(not state)
            end)

            return {
                Set = set,
                Get = function() return state end,
            }
        end

        function Tab:CreateSlider(params)
            params = params or {}
            local text = params.Name or "Slider"
            local min = params.Range and params.Range[1] or 0
            local max = params.Range and params.Range[2] or 100
            local value = params.CurrentValue or min
            local inc = params.Increment or 1
            local callback = params.Callback or function() end

            local card = makeCard(60)

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -20, 0, 18)
            lbl.Position = UDim2.new(0, 10, 0, 6)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Size = UDim2.new(0, 80, 0, 18)
            valLbl.Position = UDim2.new(1, -90, 0, 6)
            valLbl.Font = Enum.Font.GothamSemibold
            valLbl.Text = tostring(value)
            valLbl.TextColor3 = Theme.Text
            valLbl.TextSize = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = card

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -20, 0, 10)
            bar.Position = UDim2.new(0, 10, 0, 38)
            bar.BackgroundColor3 = Theme.ElementHover
            bar.Parent = card
            roundify(bar, 6)
            stroke(bar, Theme.Stroke, 1, 0.25)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.Parent = bar
            roundify(fill, 6)

            local dragging = false

            local function set(val)
                val = math.clamp(val, min, max)
                val = math.floor((val / inc) + 0.5) * inc
                value = val
                valLbl.Text = tostring(val)
                fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
                callback(val)
            end

            local function updateFromInput(x)
                local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local newVal = min + rel * (max - min)
                set(newVal)
            end

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input.Position.X)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input.Position.X)
                end
            end)

            return {
                Set = set,
                Get = function() return value end,
            }
        end

        return Tab
    end

    return Window
end

return Library
