--[[
    🎨 RYDERWINSTON UI LIBRARY - CUSTOMIZABLE TEMPLATE
    
    Extrae de testeo.lua todo lo necesario para crear versiones personalizadas
    Usa SOLO recursos profesionales de Sirius y Rayfield
    
    Usar este archivo como base para versiones customizadas
]]

-- ============================================================================
-- 📦 SERVICIOS GLOBALES (NO MODIFICAR)
-- ============================================================================

local getgenv = getgenv or function() return {} end
local function getService(name)
    local service = game:GetService(name)
    return if cloneref then cloneref(service) else service
end

local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local RunService = getService("RunService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local HttpService = getService("HttpService")

-- ============================================================================
-- ⚙️ CONFIGURACIÓN CUSTOMIZABLE
-- ============================================================================

local Config = {
    -- Identidad de la UI
    LibraryName = "Ryderwinston",           -- PERSONALIZAR: Nombre de tu biblioteca
    Version = "1.0.0",                      -- PERSONALIZAR: Tu versión
    ReleaseDate = "January 2026",           -- PERSONALIZAR: Fecha de lanzamiento
    BuildID = "RW_V1",                      -- PERSONALIZAR: ID único de build
    
    -- Carpetas y configuración
    FolderName = "Ryderwinston",            -- PERSONALIZAR: Nombre de carpeta en filesystem
    ConfigFolder = "Ryderwinston/Configurations", -- PERSONALIZAR: Carpeta de configs
    FileExtension = ".rwst",                -- PERSONALIZAR: Extensión de archivos
    
    -- Keybind por defecto
    DefaultKeybind = "K",                   -- PERSONALIZAR: Tecla para abrir/cerrar
    
    -- Prompts y notificaciones
    ShowStartupPrompt = false,              -- PERSONALIZAR: Mostrar prompt al inicio
    ShowAutoNotifications = true,           -- PERSONALIZAR: Notificaciones periódicas
    NotificationInterval = 180,             -- PERSONALIZAR: Segundos entre notificaciones
    
    -- URLs Profesionales (mantener pero personalizar si tienes alternativas)
    URLs = {
        Prompts = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua",
        Analytics = "https://analytics.sirius.menu/script",
        Icons = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua",
        Discord = "https://discord.com",
    },
    
    -- RBXAssetIDs (mantener - son oficiales de Roblox)
    Assets = {
        GUI = "rbxassetid://10804731440",       -- GUI Principal
        KeySystem = "rbxassetid://11380036235", -- Key System
        IconExpand = "rbxassetid://10137941941",
        IconMinimize = "rbxassetid://11036884234",
    },
}
local ICON_MINIMIZE = "rbxassetid://11036884234"    -- Minimizar

-- ============================================================================
-- 📋 CONFIGURACIÓN RYDERWINSTON
-- ============================================================================

local Release = "Ryderwinston UI v1.0.0 - January 2026"
local InterfaceBuild = 'RW_V1'
local RyderwinstonFolder = "Ryderwinston"
local ConfigurationFolder = RyderwinstonFolder.."/Configurations"
local ConfigurationExtension = ".rwst"

-- ============================================================================
-- 🎨 TEMAS PROFESIONALES (8 TEMAS)
-- ============================================================================

local THEMES = {
	Default = {
		TextColor = Color3.fromRGB(240, 240, 240),
		Background = Color3.fromRGB(25, 25, 25),
		Topbar = Color3.fromRGB(34, 34, 34),
		Shadow = Color3.fromRGB(20, 20, 20),
		TabBackground = Color3.fromRGB(80, 80, 80),
		TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
		ElementBackground = Color3.fromRGB(35, 35, 35),
		ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
		ElementStroke = Color3.fromRGB(50, 50, 50),
		SliderBackground = Color3.fromRGB(50, 138, 220),
		SliderProgress = Color3.fromRGB(50, 138, 220),
		ToggleEnabled = Color3.fromRGB(0, 146, 214),
		ToggleDisabled = Color3.fromRGB(100, 100, 100),
		InputBackground = Color3.fromRGB(30, 30, 30),
		InputStroke = Color3.fromRGB(65, 65, 65),
	},
	
	Ocean = {
		TextColor = Color3.fromRGB(230, 240, 240),
		Background = Color3.fromRGB(20, 30, 30),
		Topbar = Color3.fromRGB(25, 40, 40),
		Shadow = Color3.fromRGB(15, 20, 20),
		TabBackground = Color3.fromRGB(40, 60, 60),
		TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
		ElementBackground = Color3.fromRGB(30, 50, 50),
		ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
		SliderBackground = Color3.fromRGB(0, 110, 110),
		ToggleEnabled = Color3.fromRGB(0, 130, 130),
	},
	
	AmberGlow = {
		TextColor = Color3.fromRGB(255, 245, 230),
		Background = Color3.fromRGB(45, 30, 20),
		Topbar = Color3.fromRGB(55, 40, 25),
		Shadow = Color3.fromRGB(35, 25, 15),
		TabBackground = Color3.fromRGB(75, 50, 35),
		TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
		ElementBackground = Color3.fromRGB(60, 45, 35),
		SliderBackground = Color3.fromRGB(220, 130, 60),
		ToggleEnabled = Color3.fromRGB(240, 130, 30),
	},
	
	Light = {
		TextColor = Color3.fromRGB(40, 40, 40),
		Background = Color3.fromRGB(245, 245, 245),
		Topbar = Color3.fromRGB(230, 230, 230),
		Shadow = Color3.fromRGB(200, 200, 200),
		TabBackground = Color3.fromRGB(235, 235, 235),
		TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
		ElementBackground = Color3.fromRGB(240, 240, 240),
		ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
		ToggleEnabled = Color3.fromRGB(0, 146, 214),
	},
	
	Amethyst = {
		TextColor = Color3.fromRGB(240, 240, 240),
		Background = Color3.fromRGB(30, 20, 40),
		Topbar = Color3.fromRGB(40, 25, 50),
		Shadow = Color3.fromRGB(20, 15, 30),
		TabBackground = Color3.fromRGB(60, 40, 80),
		TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
		ElementBackground = Color3.fromRGB(45, 30, 60),
		SliderBackground = Color3.fromRGB(100, 60, 150),
		ToggleEnabled = Color3.fromRGB(120, 60, 150),
	},
	
	Serenity = {
		TextColor = Color3.fromRGB(30, 60, 30),
		Background = Color3.fromRGB(235, 245, 235),
		Topbar = Color3.fromRGB(210, 230, 210),
		Shadow = Color3.fromRGB(200, 220, 200),
		TabBackground = Color3.fromRGB(215, 235, 215),
		TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
		ElementBackground = Color3.fromRGB(225, 240, 225),
		ToggleEnabled = Color3.fromRGB(60, 130, 60),
	},
	
	Bloom = {
		TextColor = Color3.fromRGB(60, 40, 50),
		Background = Color3.fromRGB(255, 240, 245),
		Topbar = Color3.fromRGB(250, 220, 225),
		Shadow = Color3.fromRGB(230, 190, 195),
		TabBackground = Color3.fromRGB(240, 210, 220),
		TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
		ElementBackground = Color3.fromRGB(255, 235, 240),
		ToggleEnabled = Color3.fromRGB(255, 140, 170),
	},
	
	DarkBlue = {
		TextColor = Color3.fromRGB(230, 230, 230),
		Background = Color3.fromRGB(20, 25, 30),
		Topbar = Color3.fromRGB(30, 35, 40),
		Shadow = Color3.fromRGB(15, 20, 25),
		TabBackground = Color3.fromRGB(35, 40, 45),
		TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
		ElementBackground = Color3.fromRGB(30, 35, 40),
		SliderBackground = Color3.fromRGB(0, 90, 180),
		ToggleEnabled = Color3.fromRGB(0, 120, 210),
	}
}

-- ============================================================================
-- ⚙️ ANIMACIONES CON TWEENSERVICE
-- ============================================================================

local TweenService = getService("TweenService")

local function AnimateElement(element, property, value, duration, easing)
	duration = duration or 0.6
	easing = easing or Enum.EasingStyle.Exponential
	
	local tweenInfo = TweenInfo.new(duration, easing)
	local tween = TweenService:Create(element, tweenInfo, {[property] = value})
	tween:Play()
	
	return tween
end

-- Ejemplos de animaciones comunes:
--[[
	AnimateElement(button, "BackgroundColor3", Color3.fromRGB(40, 40, 40), 0.6)
	AnimateElement(text, "TextTransparency", 0, 0.7)
	AnimateElement(frame, "Size", UDim2.new(0, 500, 0, 475), 0.7)
	AnimateElement(element, "BackgroundTransparency", 0.3, 0.4)
]]

-- ============================================================================
-- 🎬 FUNCIÓN DE PANTALLA DE CARGA
-- ============================================================================

local function CreateLoadingScreen(title, subtitle, version)
	print("[Ryderwinston] Cargando UI...")
	print("  Título: " .. title)
	print("  Subtítulo: " .. subtitle)
	print("  Versión: " .. version)
	
	-- Simulación de animación de carga
	-- En una aplicación real, esto se conectaría con el LoadingFrame del GUI
	
	task.wait(0.5)
	print("[Ryderwinston] ✅ UI Cargada correctamente!")
end

-- ============================================================================
-- 📦 ESTRUCTURA DE ELEMENTOS UI
-- ============================================================================

local function CreateButton(name, callback, theme)
	print("[UI] Creando botón: " .. name)
	return {
		Name = name,
		Type = "Button",
		Callback = callback,
		BackgroundColor = theme.ElementBackground,
		HoverColor = theme.ElementBackgroundHover,
		TextColor = theme.TextColor,
	}
end

local function CreateToggle(name, defaultValue, callback, theme)
	print("[UI] Creando toggle: " .. name)
	return {
		Name = name,
		Type = "Toggle",
		CurrentValue = defaultValue,
		Callback = callback,
		EnabledColor = theme.ToggleEnabled,
		DisabledColor = theme.ToggleDisabled,
		TextColor = theme.TextColor,
	}
end

local function CreateSlider(name, min, max, default, suffix, callback, theme)
	print("[UI] Creando slider: " .. name)
	return {
		Name = name,
		Type = "Slider",
		Min = min,
		Max = max,
		CurrentValue = default,
		Suffix = suffix or "",
		Callback = callback,
		BackgroundColor = theme.SliderBackground,
		ProgressColor = theme.SliderProgress,
		TextColor = theme.TextColor,
	}
end

local function CreateInput(name, placeholder, callback, theme)
	print("[UI] Creando input: " .. name)
	return {
		Name = name,
		Type = "Input",
		Placeholder = placeholder,
		Callback = callback,
		BackgroundColor = theme.InputBackground,
		TextColor = theme.TextColor,
	}
end

local function CreateDropdown(name, options, default, callback, theme)
	print("[UI] Creando dropdown: " .. name)
	return {
		Name = name,
		Type = "Dropdown",
		Options = options,
		CurrentOption = default,
		Callback = callback,
		BackgroundColor = theme.ElementBackground,
		TextColor = theme.TextColor,
	}
end

-- ============================================================================
-- 🖼️ EJEMPLO DE USO COMPLETO
-- ============================================================================

print("=".."=":rep(50))
print("🎨 RYDERWINSTON UI LIBRARY - TEST")
print("=".."=":rep(50))

-- Cargar pantalla de carga
CreateLoadingScreen("Ryderwinston", "UI Library", Release)

-- Seleccionar tema
local CurrentTheme = THEMES.Default
print("\n[Config] Tema seleccionado: Default")

-- Crear elementos de ejemplo
local Tab1Elements = {
	CreateButton("Botón de Prueba", function()
		print("✅ Botón presionado!")
	end, CurrentTheme),
	
	CreateToggle("Activar Modo", true, function(value)
		print("Toggle: " .. tostring(value))
	end, CurrentTheme),
	
	CreateSlider("Volumen", 0, 100, 50, "%", function(value)
		print("Volumen: " .. value .. "%")
	end, CurrentTheme),
	
	CreateInput("Nombre", "Escribe aquí...", function(text)
		print("Input: " .. text)
	end, CurrentTheme),
	
	CreateDropdown("Opción", {"Opción 1", "Opción 2", "Opción 3"}, "Opción 1", function(selected)
		print("Seleccionado: " .. selected)
	end, CurrentTheme),
}

-- Listar elementos creados
print("\n[UI] Elementos creados en Tab 1:")
for i, element in ipairs(Tab1Elements) do
	print("  " .. i .. ". " .. element.Name .. " (" .. element.Type .. ")")
end

-- ============================================================================
-- 🎨 DEMOSTRACIÓN DE TEMAS
-- ============================================================================

print("\n[Temas] Temas disponibles:")
for themeName, themeData in pairs(THEMES) do
	print("  ✓ " .. themeName)
end

-- ============================================================================
-- 📊 INFORMACIÓN DE RECURSOS
-- ============================================================================

print("\n[Recursos] URLs Profesionales:")
print("  1. Sistema de Prompts: SiriusSoftwareLtd/Sirius")
print("  2. Analytics: analytics.sirius.menu")
print("  3. Iconos Lucide: SiriusSoftwareLtd/Rayfield")
print("  4. Discord API: discord.com")

print("\n[Recursos] RBXAssetIDs:")
print("  • GUI Principal: 10804731440")
print("  • Key System: 11380036235")
print("  • Iconos: 10137941941, 11036884234")

-- ============================================================================
-- ⚙️ DEMOSTRACIÓN DE ANIMACIONES
-- ============================================================================

print("\n[Animaciones] Ejemplos disponibles:")
print("  • Transiciones de Texto (0.7s)")
print("  • Cambios de Color (0.6s)")
print("  • Redimensionamiento (0.7s)")
print("  • Cambios de Transparencia (0.4s)")

-- ============================================================================
-- 📁 SISTEMA DE CONFIGURACIÓN
-- ============================================================================

local ConfigExample = {
	["Toggle1"] = true,
	["Slider1"] = 50,
	["Input1"] = "Mi texto guardado",
	["Dropdown1"] = "Opción 2",
	["Keybind1"] = "K",
}

print("\n[Config] Estructura de guardado JSON (.rwst):")
print("  Carpeta: " .. ConfigurationFolder)
print("  Extensión: " .. ConfigurationExtension)
print("  Ubicación: " .. ConfigurationFolder .. "/[PlaceID].rwst")

-- ============================================================================
-- ✅ RESUMEN FINAL
-- ============================================================================

print("\n" .. "=".."=":rep(50))
print("✅ TEST COMPLETADO EXITOSAMENTE")
print("=".."=":rep(50))
print("\n[Info] Archivo: test_ryderwinston.lua")
print("[Info] Versión: 1.0.0")
print("[Info] Fecha: January 2026")
print("\n[Próximos Pasos]")
print("  1. Integrar en tu juego de Roblox")
print("  2. Cargar la GUI principal (rbxassetid://10804731440)")
print("  3. Crear tabs y elementos usando las funciones")
print("  4. Aplicar temas según necesidad")
print("  5. Configurar callbacks para interactividad")
print("\nDocumentación disponible en: RECURSOS_PROFESIONALES.md")
