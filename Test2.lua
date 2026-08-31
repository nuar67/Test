-- ==========================================================
--  ERAFOX LUA RNG CONTROLLER (Standalone)
--  Работает в любом Lua 5.1+ окружении.
-- ==========================================================

-- Перехват стандартного RNG
local _math_random = math.random
local _math_seed = math.randomseed

math.random = function(a, b)
    if a and b then
        return b   -- всегда максимум
    elseif a then
        return a
    else
        return 1
    end
end

math.randomseed = function(seed)
    _math_seed(1337)  -- игнорируем переданный seed
end

-- Поиск и подмена глобальных переменных шанса
local function scanGlobals()
    for key, value in pairs(_G) do
        if type(value) == "number" and value > 0 and value < 1 then
            _G[key] = 1
            print("[erafox] Patched global: ", key, "-> 1")
        end
    end
end

-- Перехват функций, возвращающих шанс (если переданы)
local function hookFunctions()
    for key, value in pairs(_G) do
        if type(value) == "function" then
            local success, result = pcall(value)
            if success and type(result) == "number" and result > 0 and result < 1 then
                local old = value
                _G[key] = function(...)
                    return 1
                end
                print("[erafox] Hooked function: ", key)
            end
        end
    end
end

-- Автозапуск
scanGlobals()
hookFunctions()
print("[erafox] RNG controller active.")

-- Функция ручного применения (вызов из консоли)
function erafox_force_chance(value)
    if not value then value = 1 end
    for key, _ in pairs(_G) do
        if type(_G[key]) == "number" and string.find(key, "chance", 1, true) then
            _G[key] = value
            print("[erafox] Forced: ", key, "=", value)
        end
    end
end

print("[erafox] Type erafox_force_chance(1) to set all.")
