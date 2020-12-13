#!/usr/bin/python
import MySQLdb
import argparse
import sys
import random
import string

def gen_rand_str(len_):
    # a=random.sample(string.ascii_letters + string.digits, len_)
    # return "".join(a)
    ret_ = ""
    for var in range(len_):
        ret_ = ret_ + random.choice(string.ascii_letters + string.digits)
    return ret_

def gen_rand_int(min_, max_):
    return random.randint(min_, max_)

parse=argparse.ArgumentParser()
# parse.add_argument("--learning_rate",type=float,default=0.01,help="initial learining rate")
parse.add_argument("--max",type=int,default=10000,help="max insert num")
parse.add_argument("--db",type=str,default="sbtest",help="db name")
parse.add_argument("--table",type=str,default="sbtest3",help="table name")
# parse.add_argument("--hidden1",type=int,default=100,help="hidden1")
flags,unparsed=parse.parse_known_args(sys.argv[1:])
# print(flags.learning_rate)
# print(flags.max_steps)
# print(flags.hidden1)
# print(unparsed)

conn= MySQLdb.connect(user='root',host='127.0.0.1', passwd='123456',db=flags.db)
cur = conn.cursor()
for var in range(flags.max):
    # ("%s %s dsfaf %s") %  ("aaa", "bbb", "3434")
    sql = ("insert into %s (k,c,pad,country,sex) values(%s, '%s', '%s', '%s', %s)") % (flags.table, gen_rand_int(1,10000000),
                                                                                gen_rand_str(110), gen_rand_str(50),
                                                                                gen_rand_str(45), gen_rand_int(0,1))
    # print("sql = ", sql)
    cur.execute(sql)
    conn.commit()

conn.close()    
