--[[
        Cryogen UI Library
        Version 0.0.1
        Developer: podkast.mp3
]]

-- Services
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local Mouse = Players.LocalPlayer:GetMouse()

local Library = {
        Connections = {},
        Palette = {
                Accent = Color3.fromRGB(145, 150, 180),
        }
}

-- Helper functions
local function New(className: string, properties: {[string]: any}?): Instance
        local Object = Instance.new(className)

        if properties then
                for property, value in properties do
                        Object[property] = value
                end
        end

        return Object
end

local function Tween(object: GuiObject, properties: {[string]: any}, info: TweenInfo?): Tween
        return TweenService:Create(object, info or TweenInfo.new(.2, Enum.EasingStyle.Sine), properties):Play()
end

local function Connect(signal: RBXScriptSignal, callback: (...any) -> ...any): RBXScriptConnection
        local Connection = signal:Connect(callback)
        table.insert(Library.Connections, Connection)
        return Connection
end

-- Helper UI funcs
local function AddCorner(object: GuiObject, amount: number?)
        return New("UICorner", {
                CornerRadius = UDim.new(0, amount or 8),
                Parent = object
        })
end

local function AddGlow(object: GuiObject, color: Color3?)
        return New("ImageLabel", {
                Size = UDim2.new(1, 16, 1, 16),
                Position = UDim2.fromOffset(-8, -8),
                BackgroundTransparency = 1,
                Image = "rbxassetid://89672238165803",
                ImageColor3 = color or Library.Palette.Accent,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(14, 14, 514, 514),
                Parent = object
        })
end

local function AddStroke(object: GuiObject, color: Color3?)
        return New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = color or Library.Palette.Accent,
                Parent = object
        })
end

-- UI shit
local Container = New("ScreenGui", {
        Parent = (gethui and gethui()) or game:GetService("CoreGui")
})
