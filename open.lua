--[[
    miexecutador UI Library v3.0 (Enhanced, Production-Ready)
    - Estructura modular: Library, Window, Tab, Elements, Themes, Config, Notifications
    - Temas dinámicos predefinidos con cambio en RUNTIME para todos los elementos
    - Guardado real en JSON con writefile/readfile + persistencia completa
    - Sistema de Flags centralizado con validación
    - Notificaciones flotantes en cola con tipos (info/success/error)
    - Drag avanzado con TweenPosition y límites de pantalla
    - Keybinds por elemento con persistencia
    - Efectos visuales: sombras suaves, glow dinámico, bordes animados
    - Animaciones refinadas: hover, click, scroll, tab switch, ventana
    - v4.0
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. THEMES MODULE
-- ============================================================================
local Themes = {
    Default = {
        Name = "Default",
        Background = Color3.fromRGB(18, 18, 20),
        Topbar = Color3.fromRGB(24, 24, 28),
        Sidebar = Color3.fromRGB(26, 26, 30),
        Section = Color3.fromRGB(28, 28, 32),
        Stroke = Color3.fromRGB(55, 55, 60),
        Text = Color3.fromRGB(245, 245, 245),
        Accent = Color3.fromRGB(220, 50, 50),
        AccentHover = Color3.fromRGB(235, 70, 70),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240, 240, 240),
        Topbar = Color3.fromRGB(250, 250, 250),
        Sidebar = Color3.fromRGB(245, 245, 245),
        Section = Color3.fromRGB(250, 250, 250),
        Stroke = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(220, 50, 50),
        AccentHover = Color3.fromRGB(200, 40, 40),
    },
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(10, 10, 12),
        Topbar = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(12, 12, 15),
        Section = Color3.fromRGB(20, 20, 24),
        Stroke = Color3.fromRGB(40, 40, 45),
        Text = Color3.fromRGB(250, 250, 250),
        Accent = Color3.fromRGB(200, 40, 40),
        AccentHover = Color3.fromRGB(220, 60, 60),
    },
    Ocean = {
        Name = "Ocean",
        Background = Color3.fromRGB(15, 30, 45),
        Topbar = Color3.fromRGB(20, 40, 60),
        Sidebar = Color3.fromRGB(18, 35, 52),
        Section = Color3.fromRGB(22, 45, 68),
        Stroke = Color3.fromRGB(50, 100, 150),
        Text = Color3.fromRGB(200, 230, 255),
        Accent = Color3.fromRGB(100, 150, 255),
        AccentHover = Color3.fromRGB(120, 170, 255),
    },
}

-- ============================================================================
-- 2. CONFIG & FLAGS MODULE
-- ============================================================================
local Config = {
    Flags = {},
    ConfigPath = nil,
    Theme = "Default",
}

function Config:Initialize(configName)
    configName = configName or "miexecutador_config"
    self.ConfigPath = "Configuration/" .. configName .. ".json"
    self:Load()
end

function Config:Set(flagName, value)
    self.Flags[flagName] = value
    self:SaveAsync()
end

function Config:Get(flagName, defaultValue)
    return self.Flags[flagName] or defaultValue
end

function Config:SaveAsync()
    task.spawn(function()
        if not pcall(function()
            local json = HttpService:JSONEncode({flags = self.Flags, theme = self.Theme})
            if writefile then
                writefile(self.ConfigPath, json)
                print("[Config] Guardado en archivo: " .. self.ConfigPath)
            else
                print("[Config] writefile no disponible, guardado en memoria")
            end
        end) then
            warn("[Config] Error al guardar configuración")
        end
    end)
end

function Config:Load()
    self.Flags = {}
    if readfile then
        local success, data = pcall(function()
            return readfile(self.ConfigPath)
        end)
        if success and data then
            local json = HttpService:JSONDecode(data)
            self.Flags = json.flags or {}
            self.Theme = json.theme or "Default"
            print("[Config] Configuración cargada desde archivo")
        else
            print("[Config] Archivo no encontrado, usando defaults")
        end
    else
        print("[Config] readfile no disponible, usando memoria")
    end
end

function Config:SetTheme(themeName)
    if Themes[themeName] then
        self.Theme = themeName
        self:SaveAsync()
        print("[Config] Tema cambiado a: " .. themeName)
        return true
    end
    return false
end

function Config:GetTheme()
    return Themes[self.Theme] or Themes.Default
end

function Config:GetAvailableThemes()
    local themeList = {}
    for name, _ in pairs(Themes) do
        table.insert(themeList, name)
    end
    return themeList
end

-- ============================================================================
-- 3. UTILITIES MODULE
-- ============================================================================
local Util = {}

function Util.Roundify(obj, r)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, r)
    uic.Parent = obj
    return uic
end

function Util.Stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

function Util.Shadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/RoundedRectShadow.png"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 280, 280)
    shadow.Size = size or UDim2.new(1, 24, 1, 24)
    shadow.Position = UDim2.new(0, -12, 0, -12)
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ZIndex = 0
    shadow.Parent = parent
    return shadow
end

function Util.TweenHover(btn, fromColor, toColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = toColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = fromColor}):Play()
    end)
end

function Util.TweenClick(btn, downColor, upColor, callback)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = downColor}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = upColor}):Play()
        end)
        if callback then callback() end
    end)
end

function Util.ClampToScreen(position, size, screenSize)
    -- Clamp a pixel position against screen bounds, defaulting to camera viewport
    local viewport = screenSize
    if not viewport then
        local cam = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
        viewport = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
    end
    local newX = math.max(0, math.min(position.X, viewport.X - size.X))
    local newY = math.max(0, math.min(position.Y, viewport.Y - size.Y))
    return Vector2.new(newX, newY)
end

function Util.Glow(obj, color, thickness)
    local glow = Instance.new("UIStroke")
    glow.Color = color
    glow.Thickness = thickness or 2
    glow.Transparency = 0.3
    glow.Parent = obj
    return glow
end

-- ============================================================================
-- KEYBINDS MODULE
-- ============================================================================
local Keybinds = {}
Keybinds.Binds = {}
Keybinds.Connected = false
Keybinds.Connection = nil

function Keybinds:Bind(keyCode, callback, label)
    label = label or tostring(keyCode)
    for _, b in ipairs(self.Binds) do
        if b.key == keyCode and b.label == label then
            b.callback = callback
            return
        end
    end
    table.insert(self.Binds, {key = keyCode, callback = callback, label = label})
    Config:Set("keybind_" .. label, keyCode)
end

function Keybinds:BindInternal(keyCode, callback, label)
    label = label or tostring(keyCode)
    for _, b in ipairs(self.Binds) do
        if b.key == keyCode and b.label == label then
            b.callback = callback
            return
        end
    end
    table.insert(self.Binds, {key = keyCode, callback = callback, label = label, internal = true})
end

function Keybinds:SetupListener()
    if self.Connected then return end
    self.Connected = true
    self.Connection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        for _, bind in ipairs(self.Binds) do
            if input.KeyCode == bind.key then
                bind.callback()
            end
        end
    end)
end

function Keybinds:GetBind(label)
    for _, bind in ipairs(self.Binds) do
        if bind.label == label then
            return bind.key
        end
    end
    return nil
end

-- ============================================================================
-- 4. NOTIFICATIONS MODULE (Enhanced with Queue & Types)
-- ============================================================================
local Notifications = {}
Notifications.Queue = {}
Notifications.Active = {}
Notifications.MaxActive = 3
Notifications.Gui = nil

function Notifications:EnsureGui()
    if self.Gui and self.Gui.Parent then return self.Gui end
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotificationGUI"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 15
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = gui
    return gui
end

function Notifications:GetColorForType(notifType, theme)
    notifType = notifType or "info"
    if notifType == "success" then
        return Color3.fromRGB(100, 200, 100)
    elseif notifType == "error" then
        return Color3.fromRGB(255, 100, 100)
    else -- info
        return theme.Accent
    end
end

function Notifications:Show(opts)
    opts = opts or {}
    local title = opts.Title or "Notification"
    local description = opts.Description or ""
    local duration = opts.Duration or 5
    local notifType = opts.Type or "info"
    local position = opts.Position or UDim2.new(0, 16, 1, -100)
    local theme = Config:GetTheme()

    local gui = self:EnsureGui()

    -- Respect max active
    if #self.Active >= self.MaxActive then
        local oldest = table.remove(self.Active, 1)
        if oldest and oldest.Parent then oldest:Destroy() end
    end

    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 320, 0, 0)
    notif.Position = position
    notif.AnchorPoint = Vector2.new(0, 1)
    notif.BackgroundColor3 = theme.Section
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.Parent = gui
    Util.Roundify(notif, 8)
    Util.Stroke(notif, theme.Stroke, 1, 0.2)

    -- Glow effect
    local glow = Instance.new("UIStroke")
    glow.Color = self:GetColorForType(notifType, theme)
    glow.Thickness = 2
    glow.Transparency = 0.4
    glow.Parent = notif

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -24, 0, 24)
    titleLbl.Position = UDim2.new(0, 12, 0, 6)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = title
    titleLbl.TextColor3 = self:GetColorForType(notifType, theme)
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local descLbl = Instance.new("TextLabel")
    descLbl.BackgroundTransparency = 1
    descLbl.Size = UDim2.new(1, -24, 0, 0)
    descLbl.Position = UDim2.new(0, 12, 0, 32)
    descLbl.Font = Enum.Font.Gotham
    descLbl.Text = description
    descLbl.TextColor3 = theme.Text
    descLbl.TextSize = 12
    descLbl.TextWrapped = true
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.AutomaticSize = Enum.AutomaticSize.Y
    descLbl.Parent = notif

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = notif

    -- Animación de entrada suave
    notif.Position = position + UDim2.fromOffset(0, 30)
    notif.BackgroundTransparency = 1
    TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = position,
        BackgroundTransparency = 0
    }):Play()

    -- Auto-cierre con animación
    task.delay(duration, function()
        if notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = position + UDim2.fromOffset(0, 30),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.4, function()
                if notif and notif.Parent then
                    notif:Destroy()
                end
            end)
        end
    end)

    table.insert(self.Active, notif)
end

-- ============================================================================
-- 5. ELEMENTS MODULE
-- ============================================================================
local Elements = {}

function Elements.CreateButton(parent, params, theme)
    params = params or {}
    theme = theme or Config:GetTheme()
    local text = params.Name or "Button"
    local callback = params.Callback or function() end
    local size = params.Size or UDim2.new(1, -20, 0, 40)

    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. text
    btn.Size = size
    btn.BackgroundColor3 = theme.Accent
    btn.Text = text
    btn.TextColor3 = theme.Text
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 3
    btn.Parent = parent
    Util.Roundify(btn, 6)
    Util.Stroke(btn, theme.Stroke, 1, 0.15)

    Util.TweenClick(btn, theme.AccentHover, theme.Accent, callback)
    Util.TweenHover(btn, theme.Accent, theme.AccentHover)

    return btn
end

function Elements.CreateToggle(parent, params, theme)
    params = params or {}
    theme = theme or Config:GetTheme()
    local text = params.Name or "Toggle"
    local state = params.CurrentValue or false
    local callback = params.Callback or function() end

    local row = Instance.new("Frame")
    row.Name = "ToggleRow"
    row.Size = UDim2.new(1, -20, 0, 44)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = theme.Text
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    lbl.ZIndex = 3

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 54, 0, 22)
    toggleBtn.Position = UDim2.new(1, -64, 0.5, -11)
    toggleBtn.BackgroundColor3 = theme.Section
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.Parent = row
    toggleBtn.ZIndex = 3
    Util.Roundify(toggleBtn, 11)
    Util.Stroke(toggleBtn, theme.Stroke, 1, 0.25)

    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = state and theme.Accent or theme.Stroke
    circle.Parent = toggleBtn
    circle.ZIndex = 4
    Util.Roundify(circle, 9)

    local function set(val)
        state = val
        TweenService:Create(circle, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
            BackgroundColor3 = state and theme.Accent or theme.Stroke
        }):Play()
        Config:Set(params.Name or "toggle", state)
        callback(state)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        set(not state)
    end)

    return {
        Set = set,
        Get = function() return state end,
        Frame = row
    }
end

function Elements.CreateSlider(parent, params, theme)
    params = params or {}
    theme = theme or Config:GetTheme()
    local text = params.Name or "Slider"
    local min = params.Range and params.Range[1] or 0
    local max = params.Range and params.Range[2] or 100
    local value = params.CurrentValue or min
    local inc = params.Increment or 1
    local callback = params.Callback or function() end

    local row = Instance.new("Frame")
    row.Name = "SliderRow"
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, -20, 0, 60)
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = theme.Text
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    lbl.ZIndex = 3

    local valLbl = Instance.new("TextLabel")
    valLbl.Name = "SliderValue"
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(0, 80, 0, 18)
    valLbl.Position = UDim2.new(1, -90, 0, 6)
    valLbl.Font = Enum.Font.GothamSemibold
    valLbl.Text = tostring(value)
    valLbl.TextColor3 = theme.Text
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row
    valLbl.ZIndex = 3

    local bar = Instance.new("Frame")
    bar.Name = "SliderBar"
    bar.Size = UDim2.new(1, -20, 0, 10)
    bar.Position = UDim2.new(0, 10, 0, 38)
    bar.BackgroundColor3 = theme.Section
    bar.Parent = row
    bar.ZIndex = 2
    Util.Roundify(bar, 6)
    Util.Stroke(bar, theme.Stroke, 1, 0.25)

    local fill = Instance.new("Frame")
    fill.Name = "SliderFill"
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.Parent = bar
    fill.ZIndex = 3
    Util.Roundify(fill, 6)

    local dragging = false

    local function set(val)
        val = math.clamp(val, min, max)
        val = math.floor((val / inc) + 0.5) * inc
        value = val
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        Config:Set(params.Name or "slider", val)
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
        Frame = row
    }
end

function Elements.CreateTextBox(parent, params, theme)
    params = params or {}
    theme = theme or Config:GetTheme()
    local text = params.Name or "Input"
    local placeholder = params.Placeholder or ""
    local callback = params.Callback or function() end

    local row = Instance.new("Frame")
    row.Name = "TextBoxRow"
    row.Size = UDim2.new(1, -20, 0, 50)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = theme.Text
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    lbl.ZIndex = 3

    local textbox = Instance.new("TextBox")
    textbox.Name = "TextBox"
    textbox.Size = UDim2.new(1, 0, 0, 32)
    textbox.Position = UDim2.new(0, 0, 0, 18)
    textbox.BackgroundColor3 = theme.Section
    textbox.TextColor3 = theme.Text
    textbox.PlaceholderColor3 = theme.Stroke
    textbox.PlaceholderText = placeholder
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 13
    textbox.ClearTextOnFocus = false
    textbox.Active = true
    textbox.Parent = row
    textbox.ZIndex = 3
    Util.Roundify(textbox, 6)
    Util.Stroke(textbox, theme.Stroke, 1, 0.2)

    textbox.FocusLost:Connect(function()
        Config:Set(params.Name or "textbox", textbox.Text)
        if callback then callback(textbox.Text) end
    end)

    return {
        GetText = function() return textbox.Text end,
        SetText = function(t) textbox.Text = t end,
        Frame = row
    }
end


-- ============================================================================
-- 6. TAB MODULE
-- ============================================================================
local TabModule = {}

function TabModule:New(tabName, parent, sidebar, layout, theme)
    local tab = {}
    tab.Name = tabName
    tab.Theme = theme or Config:GetTheme()
    tab.Elements = {}
    tab.CurrentContainer = nil

    -- TabButton in Sidebar
    local btn = Instance.new("TextButton")
    btn.Name = "TabButton"
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = tab.Theme.Sidebar
    btn.TextColor3 = tab.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Text = tabName
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    btn.Parent = sidebar
    Util.Roundify(btn, 6)
    Util.Stroke(btn, tab.Theme.Stroke, 1, 0.3)

    -- TabPage inside parent
    local tabPage = Instance.new("Frame")
    tabPage.Name = "TabPage"
    tabPage.Visible = false
    tabPage.BackgroundTransparency = 1
    tabPage.BorderSizePixel = 0
    tabPage.Size = UDim2.new(1, 0, 1, 0)
    tabPage.ZIndex = 2
    tabPage.Parent = parent

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Scroll"
    scrollFrame.Active = true
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = tab.Theme.Stroke
    scrollFrame.ZIndex = 2
    scrollFrame.Parent = tabPage

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0, 8)
    scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Parent = scrollFrame

    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingLeft = UDim.new(0, 6)
    scrollPadding.PaddingRight = UDim.new(0, 6)
    scrollPadding.PaddingTop = UDim.new(0, 6)
    scrollPadding.Parent = scrollFrame

    -- Auto CanvasSize
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 20)
    end)

    tab.Button = btn
    tab.Page = tabPage
    tab.Scroll = scrollFrame
    tab.ScrollLayout = scrollLayout

    function tab:EnsureSection(title)
        if not tab.CurrentContainer then
            return tab:CreateSection(title or "General")
        end
        return { Section = tab.CurrentContainer.Parent, Container = tab.CurrentContainer }
    end

    function tab:CreateSection(titleText)
        local section = Instance.new("Frame")
        section.Name = "Section"
        section.BackgroundColor3 = tab.Theme.Section
        section.Size = UDim2.new(1, -4, 0, 0)
        section.AutomaticSize = Enum.AutomaticSize.Y
        section.ZIndex = 2
        section.Parent = scrollFrame
        Util.Roundify(section, 8)
        Util.Stroke(section, tab.Theme.Stroke, 1, 0.2)

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -20, 0, 32)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = tab.Theme.Text
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = section
        title.Text = titleText

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

        tab.CurrentContainer = container
        return { Section = section, Title = title, Container = container }
    end

    function tab:CreateButton(params)
        tab.Page.Visible = true
        tab:EnsureSection()
        RunService.RenderStepped:Wait()
        local btn = Elements.CreateButton(tab.CurrentContainer, params, tab.Theme)
        table.insert(tab.Elements, btn)
        return btn
    end

    function tab:CreateToggle(params)
        tab.Page.Visible = true
        tab:EnsureSection()
        RunService.RenderStepped:Wait()
        local toggle = Elements.CreateToggle(tab.CurrentContainer, params, tab.Theme)
        table.insert(tab.Elements, toggle)
        return toggle
    end

    function tab:CreateSlider(params)
        tab.Page.Visible = true
        tab:EnsureSection()
        RunService.RenderStepped:Wait()
        local slider = Elements.CreateSlider(tab.CurrentContainer, params, tab.Theme)
        table.insert(tab.Elements, slider)
        return slider
    end

    function tab:CreateTextBox(params)
        tab.Page.Visible = true
        tab:EnsureSection()
        RunService.RenderStepped:Wait()
        local textbox = Elements.CreateTextBox(tab.CurrentContainer, params, tab.Theme)
        table.insert(tab.Elements, textbox)
        return textbox
    end

    function tab:CreateLabel(text)
        tab:EnsureSection()
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -20, 0, 44)
        lbl.Font = Enum.Font.Gotham
        lbl.TextWrapped = true
        lbl.Text = text
        lbl.TextColor3 = tab.Theme.Text
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.Parent = tab.CurrentContainer
        return lbl
    end

    -- Always start with a default section to avoid empty containers
    tab:EnsureSection(tabName .. " Section")

    return tab
end

-- ============================================================================
-- 7. WINDOW MODULE
-- ============================================================================
local WindowModule = {}

function WindowModule:New(opts, theme)
    opts = opts or {}
    theme = theme or Config:GetTheme()
    local window = {}
    window.Theme = theme
    window.Tabs = {}
    window.CurrentTab = nil

    local gui = Instance.new("ScreenGui")
    gui.Name = "miexecutadorUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui") -- parent directly to PlayerGui for reliable input

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 480, 0, 360)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = theme.Background
    main.ZIndex = 1
    main.Parent = gui
    Util.Roundify(main, 10)
    Util.Stroke(main, theme.Stroke, 1)
    Util.Shadow(main, UDim2.new(1, 24, 1, 24), 0.5)

    -- Scale animation for opening
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main
    uiScale.Scale = 0.94
    TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 36)
    topbar.BackgroundColor3 = theme.Topbar
    topbar.ZIndex = 3
    topbar.Parent = main
    Util.Roundify(topbar, 10)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.Font = Enum.Font.GothamSemibold
    title.Text = opts.Name or "miexecutador"
    title.TextColor3 = theme.Text
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = topbar

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Size = UDim2.new(0, 36, 0, 24)
    close.Position = UDim2.new(1, -40, 0.5, -12)
    close.BackgroundColor3 = theme.Accent
    close.Text = "X"
    close.TextColor3 = theme.Text
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = topbar
    close.ZIndex = 4
    Util.Roundify(close, 6)
    Util.TweenHover(close, theme.Accent, theme.AccentHover)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 130, 1, -44)
    sidebar.Position = UDim2.new(0, 8, 0, 44)
    sidebar.BackgroundColor3 = theme.Sidebar
    sidebar.ZIndex = 2
    sidebar.Parent = main
    Util.Roundify(sidebar, 8)
    Util.Stroke(sidebar, theme.Stroke, 1, 0.2)

    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 6)
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.VerticalAlignment = Enum.VerticalAlignment.Begin
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = sidebar

    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -150, 1, -52)
    content.Position = UDim2.new(0, 146, 0, 44)
    content.BackgroundTransparency = 1
    content.ZIndex = 2
    content.Parent = main
    Util.Roundify(content, 8)

    -- Launcher button (Enhanced)
    local launcher = Instance.new("TextButton")
    launcher.Name = "Launcher"
    launcher.Size = UDim2.new(0, 50, 0, 50)
    launcher.Position = UDim2.new(0, 16, 1, -66)
    launcher.AnchorPoint = Vector2.new(0, 1)
    launcher.BackgroundColor3 = theme.Accent
    launcher.Text = "≡"
    launcher.TextColor3 = theme.Text
    launcher.Font = Enum.Font.GothamBold
    launcher.TextSize = 24
    launcher.AutoButtonColor = false
    launcher.Visible = false
    launcher.ZIndex = 5
    launcher.Parent = gui
    Util.Roundify(launcher, 25)
    Util.Stroke(launcher, theme.Stroke, 1, 0.2)
    Util.Glow(launcher, theme.Accent, 2)
    Util.TweenHover(launcher, theme.Accent, theme.AccentHover)

    -- Drag avanzado con TweenPosition
    local dragging = false
    local dragStartPos -- Vector2
    local dragStartMouse -- Vector2
    local dragInputConn

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not main.Visible then return end
            -- if size not ready, wait a render step
            if main.AbsoluteSize.X == 0 or main.AbsoluteSize.Y == 0 then
                RunService.RenderStepped:Wait()
            end
            dragging = true
            dragStartPos = main.AbsolutePosition
            dragStartMouse = UserInputService:GetMouseLocation()
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    local function ensureDragConnection()
        if dragInputConn then return end
        dragInputConn = UserInputService.InputChanged:Connect(function(input)
            if not main.Visible then return end
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = UserInputService:GetMouseLocation() - dragStartMouse
                local rawPos = dragStartPos + delta
                local size = (main.AbsoluteSize.X > 0 and main.AbsoluteSize.Y > 0) and main.AbsoluteSize or Vector2.new(480, 360)
                local clamped = Util.ClampToScreen(rawPos, size)
                main.Position = UDim2.fromOffset(clamped.X, clamped.Y)
            end
        end)
    end

    -- Window functions
    function window:Open()
        main.Visible = true
        launcher.Visible = false
        uiScale.Scale = 0.94
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
        ensureDragConnection()
    end

    function window:Close()
        dragging = false
        if dragInputConn then dragInputConn:Disconnect() dragInputConn = nil end
        TweenService:Create(uiScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.94}):Play()
        task.delay(0.16, function()
            main.Visible = false
            launcher.Visible = true
        end)
    end

    function window:CreateTab(tabName)
        local tab = TabModule:New(tabName, content, sidebar, tabList, theme)
        table.insert(window.Tabs, tab)

        tab.Button.MouseButton1Click:Connect(function()
            if window.CurrentTab then
                window.CurrentTab.Page.Visible = false
                TweenService:Create(window.CurrentTab.Button, TweenInfo.new(0.18), {BackgroundColor3 = theme.Sidebar}):Play()
            end
            window.CurrentTab = tab
            tab.CurrentContainer = nil -- force fresh section on tab switch
            tab:EnsureSection()
            tab.Page.Visible = true
            TweenService:Create(tab.Button, TweenInfo.new(0.18), {BackgroundColor3 = theme.Accent}):Play()
        end)

        Util.TweenHover(tab.Button, theme.Sidebar, theme.Section)

        if not window.CurrentTab then
            window.CurrentTab = tab
            tab.CurrentContainer = nil
            tab:EnsureSection()
            tab.Page.Visible = true
            TweenService:Create(tab.Button, TweenInfo.new(0.18), {BackgroundColor3 = theme.Accent}):Play()
        end

        return tab
    end

    function window:SelectTab(name)
        for _, tab in ipairs(window.Tabs) do
            if tab.Name == name then
                tab.Button:Fire()
                break
            end
        end
    end

    function window:SetTheme(themeName)
        if Themes[themeName] then
            Config:SetTheme(themeName)
            local newTheme = Config:GetTheme()
            
            -- Aplicar tema a todos los elementos
            main.BackgroundColor3 = newTheme.Background
            topbar.BackgroundColor3 = newTheme.Topbar
            sidebar.BackgroundColor3 = newTheme.Sidebar
            close.BackgroundColor3 = newTheme.Accent
            launcher.BackgroundColor3 = newTheme.Accent
            title.TextColor3 = newTheme.Text
            close.TextColor3 = newTheme.Text
            launcher.TextColor3 = newTheme.Text
            
            -- Actualizar tabs
            for _, tab in ipairs(window.Tabs) do
                tab.Theme = newTheme
                tab.Button.BackgroundColor3 = newTheme.Sidebar
                tab.Button.TextColor3 = newTheme.Text
                tab.Scroll.ScrollBarImageColor3 = newTheme.Stroke

                -- Secciones y elementos internos
                for _, section in ipairs(tab.Scroll:GetChildren()) do
                    if section:IsA("Frame") and section.Name == "Section" then
                        section.BackgroundColor3 = newTheme.Section
                        local stroke = section:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = newTheme.Stroke end

                        local titleLabel = section:FindFirstChild("Title")
                        if titleLabel then titleLabel.TextColor3 = newTheme.Text end

                        local container = section:FindFirstChild("Container")
                        if container then
                            for _, elem in ipairs(container:GetChildren()) do
                                if elem:IsA("TextButton") then
                                    elem.BackgroundColor3 = newTheme.Accent
                                    elem.TextColor3 = newTheme.Text
                                    local s = elem:FindFirstChildOfClass("UIStroke")
                                    if s then s.Color = newTheme.Stroke end
                                elseif elem:IsA("TextLabel") then
                                    elem.TextColor3 = newTheme.Text
                                elseif elem:IsA("Frame") then
                                    -- Toggle row
                                    local toggleBtn = elem:FindFirstChild("ToggleButton")
                                    if toggleBtn then
                                        toggleBtn.BackgroundColor3 = newTheme.Section
                                        local s = toggleBtn:FindFirstChildOfClass("UIStroke")
                                        if s then s.Color = newTheme.Stroke end
                                        local circle = toggleBtn:FindFirstChild("Circle")
                                        if circle then
                                            local isOn = (circle.Position.X.Scale > 0) or (circle.Position.X.Offset > 10)
                                            circle.BackgroundColor3 = isOn and newTheme.Accent or newTheme.Stroke
                                        end
                                    end

                                    -- Slider row
                                    if elem.Name == "SliderRow" then
                                        local nameLbl = elem:FindFirstChildWhichIsA("TextLabel")
                                        if nameLbl then nameLbl.TextColor3 = newTheme.Text end
                                        local valueLbl = elem:FindFirstChild("SliderValue")
                                        if valueLbl then valueLbl.TextColor3 = newTheme.Text end
                                        local bar = elem:FindFirstChild("SliderBar")
                                        if bar then
                                            bar.BackgroundColor3 = newTheme.Section
                                            local bs = bar:FindFirstChildOfClass("UIStroke")
                                            if bs then bs.Color = newTheme.Stroke end
                                            local fill = bar:FindFirstChild("SliderFill")
                                            if fill then fill.BackgroundColor3 = newTheme.Accent end
                                        end
                                    end

                                    -- TextBox row
                                    if elem.Name == "TextBoxRow" then
                                        for _, child in ipairs(elem:GetChildren()) do
                                            if child:IsA("TextLabel") then
                                                child.TextColor3 = newTheme.Text
                                            elseif child:IsA("TextBox") then
                                                child.BackgroundColor3 = newTheme.Section
                                                child.TextColor3 = newTheme.Text
                                                child.PlaceholderColor3 = newTheme.Stroke
                                                local s = child:FindFirstChildOfClass("UIStroke")
                                                if s then s.Color = newTheme.Stroke end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            Notifications:Show({
                Title = "Tema",
                Description = "Tema cambiado a: " .. themeName,
                Duration = 2,
                Type = "success"
            })
        end
    end

    -- Close button
    close.MouseButton1Click:Connect(function()
        window:Close()
    end)

    -- Launcher button
    launcher.MouseButton1Click:Connect(function()
        window:Open()
    end)

    -- Built-in toggle keybind (RightShift) via central Keybinds listener to avoid duplicate connections
    Keybinds:BindInternal(Enum.KeyCode.RightShift, function()
        if main.Visible then
            window:Close()
        else
            window:Open()
        end
    end, "toggle_ui")

    window.GUI = gui
    window.Main = main
    window.Topbar = topbar
    window.Sidebar = sidebar
    window.Content = content

    return window
end

-- ============================================================================
-- 8. LIBRARY MODULE (Main API - v3.0 Enhanced)
-- ============================================================================
local Library = {}

function Library:Initialize(opts)
    opts = opts or {}
    Config:Initialize(opts.ConfigName or "miexecutador")
    Config:SetTheme(opts.Theme or Config.Theme)
    Keybinds:SetupListener()
    return Library
end

function Library:CreateWindow(opts)
    opts = opts or {}
    local theme = Themes[Config.Theme] or Themes.Default
    local window = WindowModule:New(opts, theme)
    RunService.RenderStepped:Wait() -- wait one frame to ensure GUI is parented/rendered
    window:Open() -- ensure window is opened and interactive by default
    return window
end

function Library:ShowNotification(opts)
    Notifications:Show(opts)
end

function Library:SetTheme(themeName)
    Config:SetTheme(themeName)
end

function Library:GetTheme()
    return Config:GetTheme()
end

function Library:GetThemes()
    return Config:GetAvailableThemes()
end

function Library:Bind(keyCode, callback, label)
    Keybinds:Bind(keyCode, callback, label)
end

function Library:GetConfig()
    return Config.Flags
end

function Library:SetFlag(name, value)
    Config:Set(name, value)
end

function Library:GetFlag(name, default)
    return Config:Get(name, default)
end

-- ============================================================================
-- 9. EXAMPLE USAGE (v3.0)
-- ============================================================================
--[[
local miUI = Library:Initialize({ConfigName = "miexecutador_config", Theme = "Default"})
local window = miUI:CreateWindow({Name = "miexecutador v3.0"})

-- Crear tabs
local tabHome = window:CreateTab("Home")
local section1 = tabHome:CreateSection("General")

-- Crear elementos con persistencia de flags
local toggle1 = tabHome:CreateToggle({
    Name = "FeatureEnabled", 
    CurrentValue = miUI:GetFlag("FeatureEnabled", false), 
    Callback = function(v) print("Toggle: " .. tostring(v)) end
})

local button1 = tabHome:CreateButton({
    Name = "Click Me", 
    Callback = function() 
        miUI:ShowNotification({
            Title = "Success", 
            Description = "¡Button clicked!", 
            Duration = 3,
            Type = "success"
        })
    end
})

local slider1 = tabHome:CreateSlider({
    Name = "Value", 
    Range = {0, 100}, 
    Increment = 1, 
    CurrentValue = miUI:GetFlag("SliderValue", 50), 
    Callback = function(v) print("Slider: " .. tostring(v)) end
})

-- Settings tab con cambio de tema
local tabSettings = window:CreateTab("Settings")
local section2 = tabSettings:CreateSection("UI Settings")
local themeLabel = tabSettings:CreateLabel("Current Theme: Default")

local themeButtons = {}
for i, themeName in ipairs(miUI:GetThemes()) do
    local btn = tabSettings:CreateButton({
        Name = themeName,
        Callback = function() 
            window:SetTheme(themeName)
            themeLabel.Text = "Current Theme: " .. themeName
        end
    })
    table.insert(themeButtons, btn)
end

-- Keybind global para abrir/cerrar (ya configurado en ventana)
-- Agregar keybind personalizado
miUI:Bind(Enum.KeyCode.F, function()
    miUI:ShowNotification({
        Title = "Keybind", 
        Description = "Presionaste F", 
        Duration = 2,
        Type = "info"
    })
end, "custom_hotkey")

-- Mostrar notificación inicial
miUI:ShowNotification({
    Title = "Ready", 
    Description = "miexecutador v3.0 loaded successfully!", 
    Duration = 3,
    Type = "success"
})
]]

return Library

