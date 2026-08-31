-- ==========================================================
--  ERAFOX ADVANCED CHANCE CONTROLLER v2.0
--  Roblox Lua | Apgrader / Upgrader / Any RNG-based system
-- ==========================================================

-- Блокировка штатного RNG
local _random = math.random
local _seed = math.randomseed
math.random = function(a, b)
    if a and b then
        return b
    else
        return 1
    end
end
math.randomseed = function(s)
    _seed(1337)
end
print("[erafox] RNG hijacked. Forced max value.")

-- Функция поиска и замены всех шансов в замыканиях
local function overrideClosures()
    local success, result = pcall(function()
        local gc = getgc(true)
        for _, func in pairs(gc) do
            if type(func) == "function" then
                local upvalues = getupvalues(func)
                for idx, val in pairs(upvalues) do
                    if type(val) == "number" and val > 0 and val < 1 then
                        debug.setupvalue(func, idx, 1)
                        print("[erafox] Patched upvalue:", val, "-> 1")
                    end
                end
            end
        end
    end)
    if not success then
        print("[erafox] Closure override failed:", result)
    end
end

-- Функция поиска объектов с атрибутами шанса
local function overrideAttributes()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local attrs = obj:GetAttributes()
            for key, val in pairs(attrs) do
                if type(val) == "number" and val > 0 and val < 1 then
                    obj:SetAttribute(key, 1)
                    print("[erafox] Patched attribute:", key, "-> 1")
                end
            end
        end
    end
end

-- Сканирование ReplicatedStorage на функции шанса
local function scanReplicated()
    for _, obj in pairs(game.ReplicatedStorage:GetChildren()) do
        if obj:IsA("ModuleScript") then
            local funcs = require(obj)
            if type(funcs) == "table" then
                for k, v in pairs(funcs) do
                    if type(v) == "function" then
                        local up = getupvalues(v)
                        for idx, val in pairs(up) do
                            if type(val) == "number" and val > 0 and val < 1 then
                                debug.setupvalue(v, idx, 1)
                                print("[erafox] Patched", k, "in", obj.Name)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Автоматический запуск всех обходов
spawn(function()
    wait(1)
    overrideClosures()
    overrideAttributes()
    scanReplicated()
    print("[erafox] All chance mechanisms overridden.")
end)

-- GUI-панель (Draggable с управлением шансом в реальном времени)
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "EraFoxController"
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.5, -140, 0.5, -80)
frame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
title.Text = "EraFox v2.0 — Chance Controller"
title.TextColor3 = Color3.new(0, 1, 0.5)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 35)
label.BackgroundTransparency = 1
label.Text = "Current Chance: 100%"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamMedium
label.TextSize = 16
label.Parent = frame

local slider = Instance.new("Slider")
slider.Size = UDim2.new(0.8, 0, 0.15, 0)
slider.Position = UDim2.new(0.1, 0, 0.45, 0)
slider.MinValue = 0
slider.MaxValue = 100
slider.Value = 100
slider.Parent = frame

local valueDisplay = Instance.new("TextLabel")
valueDisplay.Size = UDim2.new(0.2, 0, 0.2, 0)
valueDisplay.Position = UDim2.new(0.75, 0, 0.45, 0)
valueDisplay.BackgroundTransparency = 1
valueDisplay.Text = "100%"
valueDisplay.TextColor3 = Color3.new(0, 1, 0.5)
valueDisplay.Font = Enum.Font.GothamBold
valueDisplay.TextSize = 18
valueDisplay.Parent = frame

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.4, 0, 0.2, 0)
applyBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
applyBtn.BackgroundColor3 = Color3.new(0.1, 0.6, 0.3)
applyBtn.Text = "Apply to All"
applyBtn.TextColor3 = Color3.new(1, 1, 1)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 14
applyBtn.Parent = frame

slider.Changed:Connect(function(val)
    local percent = math.floor(val)
    valueDisplay.Text = percent .. "%"
    label.Text = "Current Chance: " .. percent .. "%"
    if _G.chance then _G.chance = percent / 100 end
    if _G.multi then _G.multi = percent / 100 end
end)

applyBtn.MouseButton1Click:Connect(function()
    local val = slider.Value / 100
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for key, _ in pairs(obj:GetAttributes()) do
                if string.lower(key):match("chance") or
                   string.lower(key):match("multiplier") or
                   string.lower(key):match("luck") then
                    obj:SetAttribute(key, val)
                end
            end
        end
    end
    print("[erafox] Applied chance to all attributes.")
    label.Text = "Applied " .. math.floor(slider.Value) .. "% to all."
end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.2, 0, 0.15, 0)
resetBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
resetBtn.BackgroundColor3 = Color3.new(0.6, 0.1, 0.1)
resetBtn.Text = "Reset"
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 12
resetBtn.Parent = frame

resetBtn.MouseButton1Click:Connect(function()
    slider.Value = 100
    applyBtn.MouseButton1Click:Fire()
    print("[erafox] Reset to 100%.")
end)

print("[erafox] GUI loaded. Ready.")
