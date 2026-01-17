--[[
    miexecutador UI Library (standalone)
    - Sin dependencias externas
    - Tema rojo profesional
    - Tabs, botones, toggles y sliders simples
    -v1.0
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(18, 18, 20),
    Topbar = Color3.fromRGB(24, 24, 28),
    Sidebar = Color3.fromRGB(26, 26, 30),
    Section = Color3.fromRGB(28, 28, 32),
    Stroke = Color3.fromRGB(55, 55, 60),
    Text = Color3.fromRGB(245, 245, 245),
    Accent = Color3.fromRGB(220, 50, 50),
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

local function TweenHover(btn, fromColor, toColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = toColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = fromColor}):Play()
    end)
end

local function TweenClick(btn, downColor, upColor)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = downColor}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = upColor}):Play()
        end)
    end)
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

    -- Shadow behind main
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/RoundedRectShadow.png"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.Size = UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = main

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

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 130, 1, -44)
    sidebar.Position = UDim2.new(0, 8, 0, 44)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.Parent = main
    roundify(sidebar, 8)
    stroke(sidebar, Theme.Stroke, 1, 0.2)

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 6)
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.VerticalAlignment = Enum.VerticalAlignment.Begin
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = sidebar

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -150, 1, -52)
    content.Position = UDim2.new(0, 146, 0, 44)
    content.BackgroundTransparency = 1
    content.Parent = main
    roundify(content, 8)

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
    TweenHover(close, Theme.Accent, Theme.Accent)
    TweenClick(close, Theme.Accent, Theme.Accent)

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
        -- TabButton in Sidebar
        local btn = Instance.new("TextButton")
        btn.Name = "TabButton"
        btn.Size = UDim2.new(1, -12, 0, 32)
        btn.BackgroundColor3 = Theme.Sidebar
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Text = tabName
        btn.AutoButtonColor = false
        btn.Parent = sidebar
        roundify(btn, 6)
        stroke(btn, Theme.Stroke, 1, 0.3)
        TweenHover(btn, Theme.Sidebar, Theme.Section)

        -- TabPage Frame inside Content
        local tabPage = Instance.new("Frame")
        tabPage.Name = "TabPage"
        tabPage.Visible = false
        tabPage.BackgroundTransparency = 1
        tabPage.BorderSizePixel = 0
        tabPage.Size = UDim2.new(1, 0, 1, 0)
        tabPage.Parent = content

        -- Scrolling container inside TabPage
        local page = Instance.new("ScrollingFrame")
        page.Name = "Scroll"
        page.Active = true
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 6
        page.ScrollBarImageColor3 = Theme.Stroke
        page.Parent = tabPage

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

        -- Auto CanvasSize
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        local selected = false

        local function setSelected(val)
            selected = val
            local targetColor = selected and Theme.Accent or Theme.Sidebar
            TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
        end

        local function select()
            if currentPage then
                currentPage.container.Visible = false
                TweenService:Create(currentPage.button, TweenInfo.new(0.18), {BackgroundColor3 = Theme.Sidebar}):Play()
            end
            currentPage = {container = tabPage, button = btn}
            tabPage.Visible = true
            page.Position = UDim2.new(0, 16, 0, 6)
            TweenService:Create(page, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            setSelected(true)
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

        local currentContainer

        local function makeSection()
            local section = Instance.new("Frame")
            section.Name = "Section"
            section.BackgroundColor3 = Theme.Section
            section.Size = UDim2.new(1, -4, 0, 0)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.Parent = page
            roundify(section, 8)
            stroke(section, Theme.Stroke, 1, 0.2)

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, -20, 0, 32)
            title.Position = UDim2.new(0, 10, 0, 0)
            title.Font = Enum.Font.GothamBold
            title.TextColor3 = Theme.Text
            title.TextSize = 16
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Parent = section

            local container = Instance.new("Frame")
            container.Name = "Container"
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, -20, 0, 0)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Position = UDim2.new(0, 10, 0, 32)
            container.Parent = section

            local clayout = Instance.new("UIListLayout")
            clayout.Padding = UDim.new(0, 8)
            clayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            clayout.SortOrder = Enum.SortOrder.LayoutOrder
            clayout.Parent = container

            local cpad = Instance.new("UIPadding")
            cpad.PaddingLeft = UDim.new(0, 0)
            cpad.PaddingRight = UDim.new(0, 0)
            cpad.PaddingTop = UDim.new(0, 4)
            cpad.PaddingBottom = UDim.new(0, 8)
            cpad.Parent = container

            currentContainer = container
            return section, title, container
        end

        function Tab:CreateSection(titleText)
            local section, titleLabel, container = makeSection()
            titleLabel.Text = titleText
            return {
                Section = section,
                Title = titleLabel,
                Container = container
            }
        end

        function Tab:CreateLabel(text)
            if not currentContainer then makeSection() end
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -20, 0, 44)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.Font = Enum.Font.Gotham
            lbl.TextWrapped = true
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.Parent = currentContainer
            return lbl
        end

        function Tab:CreateButton(params)
            params = params or {}
            local text = params.Name or "Button"
            local callback = params.Callback or function() end
            if not currentContainer then makeSection() end
            local btn = Instance.new("TextButton")
            btn.Name = "TextButton"
            btn.Size = UDim2.new(1, -20, 0, 40)
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.BackgroundColor3 = Theme.Accent
            btn.Text = text
            btn.TextColor3 = Theme.Text
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamBold
            btn.AutoButtonColor = false
            btn.Parent = currentContainer
            roundify(btn, 6)
            stroke(btn, Theme.Stroke, 1, 0.15)
            TweenClick(btn, Theme.Accent, Theme.Accent)
            btn.MouseButton1Click:Connect(function()
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
            if not currentContainer then makeSection() end
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -20, 0, 44)
            row.Position = UDim2.new(0, 10, 0, 0)
            row.BackgroundTransparency = 1
            row.Parent = currentContainer

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Position = UDim2.new(0, 0, 0, 0)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Name = "ToggleButton"
            toggleBtn.Size = UDim2.new(0, 54, 0, 22)
            toggleBtn.Position = UDim2.new(1, -64, 0.5, -11)
            toggleBtn.BackgroundColor3 = Theme.Section
            toggleBtn.Text = ""
            toggleBtn.AutoButtonColor = false
            toggleBtn.Parent = row
            roundify(toggleBtn, 11)
            stroke(toggleBtn, Theme.Stroke, 1, 0.25)

            local circle = Instance.new("Frame")
            circle.Name = "Circle"
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            circle.BackgroundColor3 = state and Theme.Accent or Theme.Stroke
            circle.Parent = toggleBtn
            roundify(circle, 9)

            local function set(val)
                state = val
                TweenService:Create(circle, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = state and Theme.Accent or Theme.Stroke
                }):Play()
                callback(state)
            end

            toggleBtn.MouseButton1Click:Connect(function()
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
            if not currentContainer then makeSection() end
            local containerRow = Instance.new("Frame")
            containerRow.BackgroundTransparency = 1
            containerRow.Size = UDim2.new(1, -20, 0, 60)
            containerRow.Position = UDim2.new(0, 10, 0, 0)
            containerRow.Parent = currentContainer

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -20, 0, 18)
            lbl.Position = UDim2.new(0, 10, 0, 6)
            lbl.Font = Enum.Font.Gotham
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = containerRow

            local valLbl = Instance.new("TextLabel")
            valLbl.BackgroundTransparency = 1
            valLbl.Size = UDim2.new(0, 80, 0, 18)
            valLbl.Position = UDim2.new(1, -90, 0, 6)
            valLbl.Font = Enum.Font.GothamSemibold
            valLbl.Text = tostring(value)
            valLbl.TextColor3 = Theme.Text
            valLbl.TextSize = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = containerRow

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -20, 0, 10)
            bar.Position = UDim2.new(0, 10, 0, 38)
            bar.BackgroundColor3 = Theme.Section
            bar.Parent = containerRow
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

        local Tab = {}
        Tab.Select = select
        Tab.CreateSection = Tab.CreateSection
        Tab.CreateLabel = Tab.CreateLabel
        Tab.CreateButton = Tab.CreateButton
        Tab.CreateToggle = Tab.CreateToggle
        Tab.CreateSlider = Tab.CreateSlider
        return Tab
    end

    function Window:SelectTab(name)
        -- Find and click by text
        for _, child in ipairs(sidebar:GetChildren()) do
            if child:IsA("TextButton") and child.Text == name then
                child:Activate()
                child:Release()
                child.MouseButton1Click:Fire()
                break
            end
        end
    end

    -- Keybind to toggle UI (RightShift)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if main.Visible then
                Window:Close()
            else
                Window:Open()
            end
        end
    end)

    return Window
end

return Library
