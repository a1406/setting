#!/usr/bin/env bash
cat > 1.log << EOF
drop table if exists \`sbtest3\`;
CREATE TABLE \`sbtest3\` (
  \`id\` int unsigned NOT NULL AUTO_INCREMENT,
  \`k\` int unsigned NOT NULL DEFAULT '0',
  \`c\` char(120) NOT NULL DEFAULT '',
  \`pad\` char(60) NOT NULL DEFAULT '',
  \`country\` char(50) NOT NULL DEFAULT '',
  \`sex\` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (\`id\`),
  KEY \`k_1\` (\`k\`),
  KEY \`country_1\` (\`country\`),
  KEY \`sex_1\` (\`sex\`)
) ENGINE=InnoDB;
EOF
mysql -uroot -p123456 -h127.0.0.1 sbtest < 1.log
sleep 2
for i in {1..10}; do
    # let "ii=${i} * 1000000"
    # echo "${i}: ${ii}"
    python ./init_mysql.py --max=1000000 &
done

