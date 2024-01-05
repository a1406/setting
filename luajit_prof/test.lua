name = "bob"
age= 20
mystr="hello lua"
mytable={name="tom",id=123456}
C_Func();
function add(x,y)
    print 'lua func add'
    testluaafunc(x, y);
    return 2*x+y
end

function testluaafunc(x, y)
    print 'lua func testluaafunc'    
    return testlua_bb_func(x + 1, y + 2);
end

function testlua_bb_func(x, y)
    print 'lua func bbb'        
    return testlua_cc_func(x + 3, y + 4);
end

function testlua_cc_func(x, y)
    print 'lua func cccc'            
    C_Func();
end

N=28

-- 检查(n,c)是否不会被攻击
function isplaceok(a,n,c)
    for i=1,n-1 do
        if (a[i]==c) or -- 同一列？
                (a[i]-i==c-n) or -- 同一对角线？
                (a[i]+i==c+n) then -- 同一对角线？
            return false  -- 位置会被攻击
        end
    end
    return true -- 不会被被攻击，位置有效
end

-- 打印棋盘
function printsolution(a)
    -- print("printsolution\n")
    -- for i=1,N do  -- 每一行
    --     for j=1,N do  -- 每一列
    --         -- 输出X或-，外加一个空格
    --         io.write(a[i]==j and "X" or "-"," ")
    --     end
    --     io.write("\n")
    -- end
    -- io.write("\n")
    return
end

-- 把从n到N的所有皇后放到棋盘a上
function addqueen(a,n)
    if n>N then  -- 是否所有的皇后都被放置好了？
        printsolution(a)
    else  -- 尝试防止第n个皇后
        for c=1,N do
            if isplaceok(a,n,c) then
                a[n]=c  -- 把第n个皇后放到列c
                addqueen(a,n+1)
            end
        end
    end
end

-- addqueen({},1)
function testlua_addqueen()
    addqueen({},1)
end
