# move.py
# 1. 导入gdb模块来访问gdb提供的python接口
import gdb
import re

map_re = re.compile('\[([0-9]*)\] = (0x[0-9a-f]*)')

# 2. 用户自定义命令需要继承自gdb.Command类
class Move(gdb.Command):

    # 3. docstring里面的文本是不是很眼熟？gdb会提取该类的__doc__属性作为对应命令的文档
    """Move breakpoint
    Usage: jack old_breakpoint_num new_breakpoint
    Example:
        (gdb) jack 1 binary_search -- move breakpoint 1 to `b binary_search`
    """

    def __init__(self):
        # 4. 在构造函数中注册该命令的名字
        super(self.__class__, self).__init__("jack", gdb.COMMAND_USER)

    # 5. 在invoke方法中实现该自定义命令具体的功能
    # args表示该命令后面所衔接的参数，这里通过string_to_argv转换成数组
    def invoke(self, args, from_tty):
        all_monster = gdb.parse_and_eval('monster_manager_all_monsters_id')
        a = str(all_monster)
        b = map_re.findall(a)
        for ite in b:
            key = ite[0]
            value = ite[1]
            scene_id = gdb.parse_and_eval('((monster_struct *)' + value + ')->data->scene_id')
            if scene_id != 10000:
                continue
            print("key = %s, value = %s" % (key, value))
            gdb.execute('p ((monster_struct *)' + value + ')->data->player_id')
        
#        print("monster len = %d" % len(a))
#        print(a)
#        print(type(a))
#        argv = gdb.string_to_argv(args)
#        if len(argv) <= 0:
#            raise gdb.GdbError('输入参数数目不对，help jack以获得用法')
        # 6. 使用gdb.execute来执行具体的命令
#        for ite in argv:
#            gdb.execute('p ((monster_struct *)' + ite + ')->data->move_path')
#            path = gdb.parse_and_eval('((monster_struct *)' + ite + ')->data->move_path')
#            print(path['pos']['pos_x'])
#            gdb.write(a.string())
#            yield(path['pos'])
            
        
#        gdb.execute('delete ' + argv[0])
#        gdb.execute('break ' + argv[1])

# 7. 向gdb会话注册该自定义命令
Move()
