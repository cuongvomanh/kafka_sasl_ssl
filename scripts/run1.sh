echo "Start zoo"
echo "___________"
#source ./scripts/zoo_env
export KAFKA_OPTS="-Djava.security.auth.login.config="$(pwd)"/sasl_ssl_config/zookeeper_jaas.conf"
echo "KAFKA_OPTS :"$KAFKA_OPTS
./scripts/zoo_start.sh
echo "Start kafka"
echo "___________"
#source scripts/kafka_env
export KAFKA_OPTS="-Djava.security.auth.login.config="$(pwd)"/sasl_ssl_config/kafka_server_jaas.conf"
echo "KAFKA_OPTS :"$KAFKA_OPTS
echo "KAFKA_OPTS :"$KAFKA_OPTS
./scripts/kafka_start.sh
echo "Start producer"
echo "___________"
export KAFKA_OPTS="-Djava.security.auth.login.config="$(pwd)"/sasl_ssl_config/kafka_client_jaas.conf"
export BROKER=localhost:9093
#bash scripts/producer.sh
prof="sasl_ssl_config/producer_ssl.properties" data="samples/data.txt" ./scripts/producer.sh
echo "Start consumer"
echo "___________"
export KAFKA_OPTS="-Djava.security.auth.login.config="$(pwd)"/sasl_ssl_config/kafka_client_jaas.conf"
export BROKER=localhost:9093
prof="sasl_ssl_config/consumer_ssl.properties" ./scripts/consumer.sh
#bash scripts/consumer.sh

