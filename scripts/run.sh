echo "Init cert!"
echo "___________"
mkdir sasl_ssl_config/ssl
cd sasl_ssl_config/ssl
# pass 123456a@
./run.sh
cd ../..
echo "Config pwd!"
echo "___________"
sed -i "s#/home/cuong/Staff/github/kafka_repo/sasl/new1/kafka_2.12-2.7.0#PWDODAY#g" sasl_ssl_config/server.properties
sed -i "s#PWDODAY#"$(pwd)"#g" sasl_ssl_config/server.properties
sed -i "s#/home/cuong/Staff/github/kafka_repo/sasl/new1/kafka_2.12-2.7.0#PWDODAY#g" sasl_ssl_config/consumer_ssl.properties
sed -i "s#PWDODAY#"$(pwd)"#g" sasl_ssl_config/consumer_ssl.properties
echo "Start zoo"
echo "___________"
source scripts/zoo_env
./scripts/zoo_start.sh
echo "Start kafka"
echo "___________"
source scripts/kafka_env
./scripts/kafka_start.sh
echo "Start producer"
echo "___________"
export BROKER=localhost:9093
#bash scripts/producer.sh
prof="sasl_ssl_config/producer_ssl.properties" data="samples/data.txt" ./scripts/producer.sh
echo "Start consumer"
echo "___________"
export BROKER=localhost:9093
prof="sasl_ssl_config/consumer_ssl.properties" ./scripts/consumer.sh
#bash scripts/consumer.sh
