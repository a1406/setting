#!/usr/bin/env bash

dbname="sbtest"
tbname1="sbtest4_1"
tbname2="sbtest4_2"
tbname3="sbtest4_3"

if [ "$2" != "" ]
then 
    dbname=$1
fi

cat > 1.log << EOF
drop table if exists \`${tbname2}\`;
CREATE TABLE \`${tbname2}\` (
  \`id\` int unsigned NOT NULL AUTO_INCREMENT,
  \`k\` int unsigned NOT NULL,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB;
drop table if exists \`${tbname3}\`;
CREATE TABLE \`${tbname3}\` (
  \`id\` int unsigned NOT NULL AUTO_INCREMENT,
  \`k\` int unsigned NOT NULL,
  PRIMARY KEY (\`id\`),
  KEY \`k_1\` (\`k\`)
) ENGINE=InnoDB;

EOF

mysql -uroot -p123456 -h127.0.0.1 ${dbname} < 1.log
sleep 2
for i in {1..100}; do
    # let "ii=${i} * 1000000"
    # echo "${i}: ${ii}"
    python ./init_mysql.py --max=100000 --table=${tbname2} &
    python ./init_mysql.py --max=100000 --table=${tbname3}
done

