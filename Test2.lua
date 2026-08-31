-- ==========================================================
--  ERAFOX FIXED RNG CONTROLLER (с диагностикой)
--  Копировать и запускать в экзекьюторе Roblox.
-- ==========================================================

print("[erafox] Starting diagnostics...")

-- Проверка окружения
local env_ok = true
if not pcall(function() return getgc end) then
    print("[erafox] WARNING: getgc not available.")
    env_ok = false
end
if not pcall(function() return debug end) then
    print("[erafox] WARNING: debug not available.")
    env_ok = false
end

-- Базовый перехват (работает в 100% случаев)
local old_random = math.random
local old_seed = math.randomseed

math.random = function(a, b)
    if a and b then
        return b
    elseif a then
        return a
    else
        return 1
    end
end

math.randomseed = function(s)
    old_seed(1337)
end

-- Проверка перехвата
local test = {math.random(1,100), math.random(1,100), math.random(1,100)}
if test[1] == 100 and test[2] == 100 and test[3] == 100 then
    print("[erafox] RNG hijack SUCCESS.")
else
    print("[erafox] RNG hijack FAILED. Fallback enabled.")
    _G.random = function(a, b) return b end
    _G.chance = 1
    _G.multi = 1
end

-- Подмена глобальных переменных (безопасная)
local function safePatch()
    local patched = 0
    for k, v in pairs(_G) do
        if type(v) == "number" and v > 0 and v < 1 then
            _G[k] = 1
            patched = patched + 1
            print("[erafox] Patched _G."..k.." -> 1")
        end
    end
    if patched == 0 then
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local attrs = obj:GetAttributes()
                    for ak, av in pairs(attrs) do
                        if type(av) == "number" and av > 0 and av < 1 then
                            obj:SetAttribute(ak, 1)
                            patched = patched + 1
                        end
                    end
                end
            end
        end)
    end
    print("[erafox] Total patches applied: "..patched)
end

-- Автозапуск через таймер (ждём загрузки игры)
spawn(function()
    wait(2)
    safePatch()
    print("[erafox] Controller ready.")
end)

-- Ручная команда для консоли
_G.erafox_fix = function()
    safePatch()
    print("[erafox] Manual patch applied.")
end

-- Защита от сброса (если игра перезаписывает random)
if game and game:GetService("RunService") then
    game:GetService("RunService").Heartbeat:Connect(function()
        if math.random(1,100) ~= 100 then
            math.random = function(a, b)
                if a and b then return b elseif a then return a else return 1 end
            end
        end
    end)
end

print("[erafox] Full protection active.")
