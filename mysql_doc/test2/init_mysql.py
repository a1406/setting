#!/usr/bin/python
import pymysql
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

conn= pymysql.connect(user='root',host='127.0.0.1', passwd='123456',db=flags.db)
cur = conn.cursor()
for var in range(int(flags.max / 10000)):
    sql = ("insert into %s (`k`) values") % (flags.table)
    # for var1 in range(10000):
    for var1 in range(10000):        
        if var1 == 0:
            sql = sql + ("(%s)" % gen_rand_int(1,10000000))
        else:
            sql = sql + (",(%s)" % gen_rand_int(1,10000000))

                     
    # print("sql = ", sql)
    cur.execute(sql)
    conn.commit()

conn.close()    
