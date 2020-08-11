kafka-topics.sh --bootstrap-server zookeeper-cluster_kafka3_1:9092 --list
kafka-topics.sh --bootstrap-server zookeeper-cluster_kafka3_1:9092 --create --replication-factor 3  --topic topic1
kafka-topics.sh --bootstrap-server zookeeper-cluster_kafka3_1:9092 --describe
