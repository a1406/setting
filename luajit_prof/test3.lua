function test1(N)
    for i = 1, N do
        c_test_mod2()
    end
end
function test2(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test3(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test4(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test5(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test6(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test7(N)
    for i = 1, N do
        c_test_mod2()
    end
end
function test8(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test9(N)
    for i = 1, N do
        c_test_mod()
    end
end
function test10(N)
    for i = 1, N do
        c_test_mod()
    end
end

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

