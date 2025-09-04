--[[
        Cryogen UI Library
        Version 0.0.1
        Developer: podkast.mp3
]]

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Variables
local CenterPosition = UDim2.fromScale(.5, .5)
local CenterPoint = Vector2.new(.5, .5)
local Tooltip

local Library = {
        Connections = {},
        Palette = {
                Font = Font.fromName("Inter"),
                MainBG = Color3.fromRGB(29, 30, 36),
                Accent = Color3.fromRGB(145, 150, 180),
        },

        TweenEnabled = true,
        BlurEnabled = true,

        WindowTransparency = .05,
}


-- Filesystem
for _, folder in {"Cryogen", "Cryogen/Assets"} do
        if not isfolder(folder) then
                makefolder(folder)
        end
end

-- Asset download
for _, asset in HttpService:JSONDecode(game:HttpGet("https://api.github.com/repos/cryogen-rblx/Cryogen/contents/Assets")) do
        if not isfile("Cryogen/Assets/"..asset.name) then
                writefile("Cryogen/Assets/"..asset.name, game:HttpGet(asset.download_url))
        end
end

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
        if Library.TweenEnabled then
                        return TweenService:Create(object, info or TweenInfo.new(.2, Enum.EasingStyle.Sine), properties):Play()
        else -- i hate this shit
                for property, value in properties do
                        object[property] = value
                end

                return {
                        Completed = { Connect = function() return { Disconnect = function() end } end },
                        Play = function() end,
                        Pause = function() end,
                        Cancel = function() end
                }
        end
end

local function Connect(signal: RBXScriptSignal?, callback: (...any) -> ...any): RBXScriptConnection?
        local Connection = signal:Connect(callback)
        table.insert(Library.Connections, Connection)
        return Connection
end

-- Helper UI funcs
local function Lighten(color: Color3, amount: number)
        local h, s, v = color:ToHSV()
        return Color3.fromHSV(h, s, math.clamp(select(3, Library.Palette.MainBG:ToHSV()) > 0.5 and v - amount or v + amount, 0, 1))
end

local function AddCorner(object: GuiObject, amount: number?): UICorner
        return New("UICorner", {
                CornerRadius = UDim.new(0, amount or 8),
                Parent = object
        })
end

local function AddGlow(object: GuiObject, color: Color3?): ImageLabel
        return New("ImageLabel", {
                Size = UDim2.new(1, 16, 1, 16),
                Position = UDim2.fromOffset(-8, -8),
                BackgroundTransparency = 1,
                Image = getcustomasset("Cryogen/Assets/Glow.png"),
                ImageColor3 = color or Library.Palette.Accent,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(14, 14, 514, 514),
                Parent = object
        })
end

local function AddStroke(object: GuiObject, color: Color3?): UIStroke
        return New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = color or Library.Palette.Accent,
                Parent = object
        })
end

local function AddPadding(object: GuiObject, paddings: {[string]: number}): UIPadding
        -- hold on im optimizating
        local function pad(side: string)
                return paddings[side] and UDim.new(0, paddings[side]) or UDim.new()
        end

        local Padding = New("UIPadding", {
                PaddingLeft = pad("L"),
                PaddingRight = pad("R"),
                PaddingTop = pad("T"),
                PaddingBottom = pad("B"),
                Parent = object
        })

        table.clear(paddings)

        return Padding
end

local function AddTooltip(object: GuiObject, text: string)
        Connect(object.MouseEnter, function()
                Tooltip.Visible = true
        end)

        Connect(object.MouseLeave, function()
                Tooltip.Visible = false
        end)
        Connect(object.MouseMoved, function(x, y)
                Tooltip.Position = UDim2.fromOffset(x, y)
        end)
end

-- UI shit
local Container = New("ScreenGui", {
        Parent = (gethui and gethui()) or game:GetService("CoreGui")
})

Tooltip = New("TextLabel", {
        Position = UDim2.fromScale(-1, -1),
        Size = UDim2.new(),
        AutomaticSize = Enum.AutomaticSize.XY,
        TextColor3 = Library.Palette.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
        FontFace = Library.Palette.Font,
        Visible = false,
        Parent = Container
}) AddCorner(Tooltip); AddStroke(Tooltip); AddPadding(Tooltip, {B=8, L=8, R=8, T=8})

-- Library funcs
function Library:Window(name: string)
        local Window = New("Frame", {
                Position = CenterPosition,
                AnchorPoint = CenterPoint,
                BackgroundColor3 = self.Palette.MainBG,
                BackgroundTransparency = self.WindowTransparency,
                Size = UDim2.fromOffset(600, 400),
                Parent = Container
        }) AddCorner(Window); AddStroke(Window); AddGlow(Window)

        local TitleFrame = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 66),
                Parent = Window
        })

        local function makeButton(position: UDim2, icon: string): TextButton
                local Button = New("TextButton", {
                        BackgroundColor3 = Library.Palette.Accent,
                        BackgroundTransparency = 1,
                        Position = position,
                        Size = UDim2.fromOffset(32, 32),
                        Text = "",
                        Parent = Window
                }) AddCorner(Button); local ButtonStroke = AddStroke(Button)

                local ButtonIcon = New("ImageLabel", {
                        AnchorPoint = CenterPoint,
                        Position = CenterPosition,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(16, 16),
                        Image = icon,
                        ImageColor3 = Library.Palette.MainBG
                })

                Connect(Button.MouseEnter, function()
                        Tween(Button, {BackgroundTransparency = 0})
                        Tween(ButtonStroke, {Transparency = 1})
                        Tween(ButtonIcon, {ImageColor3 = Library.Palette.Accent})
                end)

                Connect(Button.MouseLeave, function()
                        Tween(Button, {BackgroundTransparency = 1})
                        Tween(ButtonStroke, {Transparency = 0})
                        Tween(ButtonIcon, {ImageColor3 = Library.Palette.MainBG})
                end)

                Connect(Button.Mouse1ButtonDown, function()
                        Tween(Button, {BackgroundColor3 = Lighten(Library.Palette.Accent, .05)})
                end)

                Connect(Button.Mouse1ButtonUp, function()
                        Tween(Button, {BackgroundColor3 = Library.Palette.Accent})
                end)

                return Button
        end

        local TabsButton = makeButton(UDim2.fromOffset(16, 16), getcustomasset("Cryogen/Assets/Home"))
        local SearchButton = makeButton(UDim2.new(1, -96, 0, 16), getcustomasset("Cryogen/Assets/Search"))
        local MinimizeButton = makeButton(UDim2.new(1, -56, 0, 16), getcustomasset("Cryogen/Assets/Minimize"))
        local CloseButton = makeButton(UDim2.new(1, -16, 0, 16), getcustomasset("Cryogen/Assets/Close"))
        -- ...

        local WindowFunctions = {}

        function WindowFunctions:Tab(name: string, icon: string?)
                -- ...

                local TabFunctions = {}

                -- ...

                return TabFunctions
        end

        -- ...

        return WindowFunctions
end

return Library
