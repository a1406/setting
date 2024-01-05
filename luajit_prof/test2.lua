function test_mod1(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test_without_mod1(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            local v2 = floor(v / 10)
            x = v - v2 * 10
            s = s + x * x * x
            v = v2
        end

        if s == i then
            -- print(s)
        end
    end
end

function test1(N)
    for i = 1, N do
        test_mod1(5000000 * 2)
    end
end
-- for i = 1, 100 do
--     test_without_mod1(5000000)
-- end

--============================
function test_mod2(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test2(N)
    for i = 1, N do
        test_mod2(5000000 / 2)
    end
end
--============================
function test_mod3(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test3(N)
    for i = 1, N do
        test_mod3(5000000)
    end
end
--============================
function test_mod4(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test4(N)
    for i = 1, N do
        test_mod4(5000000)
    end
end
--============================
function test_mod5(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test5(N)
    for i = 1, N do
        test_mod5(5000000)
    end
end
--============================
function test_mod6(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test6(N)
    for i = 1, N do
        test_mod6(5000000)
    end
end
--============================
function test_mod7(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test7(N)
    for i = 1, N do
        test_mod7(5000000)
    end
end
--============================
function test_mod8(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test8(N)
    for i = 1, N do
        test_mod8(5000000)
    end
end
--============================
function test_mod9(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test9(N)
    for i = 1, N do
        test_mod9(5000000)
    end
end
--============================
function test_mod10(N)
    local floor = math.floor

    for i = 1, N do
        local v = i
        local s = 0
        while v > 0 do
            x = v % 10
            s = s + x * x * x
            v = floor(v / 10)
        end

        if s == i then
            -- print(s)
        end
    end
end

function test10(N)
    for i = 1, N do
        test_mod10(5000000)
    end
end

--===============================

function testmain(seed)
    -- print("testmain seed = " .. seed)
    math.randomseed(seed)
    for i = 1, 100 do
        index1 = math.floor(math.random() * 1000000000)
        index1 = i
        index = index1 % 10 + 1
        -- print("index = " .. index1 .. ", index2 = " .. index)
        if index == 1 then
            test1(10)
        end
        if index == 2 then
            test2(10)
        end
        if index == 3 then
            test3(10)
        end
        if index == 4 then
            test4(10)
        end
        if index == 5 then
            test5(10)
        end
        if index == 6 then
            test6(10)
        end
        if index == 7 then
            test7(10)
        end
        if index == 8 then
            test8(10)
        end
        if index == 9 then
            test9(10)
        end
        if index == 10 then
            test10(10)
        end
    end
end
