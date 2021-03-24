[ -z "$is_ssl" ] && is_ssl="true"
[ -z "$is_create_cert" ] && is_create_cert="true"
echo "is_ssl: "$is_ssl
if [ "$is_ssl" = "false" ] ;then
    echo "Using SASL only for kafka"
else 
    echo "Using SASL SSL for kafka"
fi

if [ "$is_ssl" = "true" && "$is_create_cert" = "true" ] ;then
    echo "Init cert!"
    echo "___________"
    [ ! -d "sasl_ssl_config/ssl" ] && mkdir sasl_ssl_config/ssl
    cd sasl_ssl_config/ssl
    # pass 123456a@
    ./run.sh
    cd ../..
fi
if [ "$is_ssl" = "true" ] ;then
    sed -i "s/^#ssl\./ssl./g" sasl_ssl_config/server.properties
else 
    sed -i "s/^ssl\./#ssl./g" sasl_ssl_config/server.properties
    export BROKER=localhost:9092
fi
echo "Config pwd!"
echo "___________"
sed -i "s#/home/cuong/Staff/github/kafka_repo/sasl/new1/kafka_2.12-2.7.0#PWDODAY#g" sasl_ssl_config/server.properties
sed -i "s#PWDODAY#"$(pwd)"#g" sasl_ssl_config/server.properties
sed -i "s#/home/cuong/Staff/github/kafka_repo/sasl/new1/kafka_2.12-2.7.0#PWDODAY#g" sasl_ssl_config/consumer_ssl.properties
sed -i "s#PWDODAY#"$(pwd)"#g" sasl_ssl_config/consumer_ssl.properties
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

#bash scripts/producer.sh
if [ "$is_ssl" = "true" ] ;then export BROKER=localhost:9093; export prof="sasl_ssl_config/producer_ssl.properties"; fi
data="samples/data.txt" ./scripts/producer.sh
echo "Start consumer"
echo "___________"
export KAFKA_OPTS="-Djava.security.auth.login.config="$(pwd)"/sasl_ssl_config/kafka_client_jaas.conf"
if [ "$is_ssl" = "true" ] ;then export BROKER=localhost:9093; export prof="sasl_ssl_config/consumer_ssl.properties"; fi
./scripts/consumer.sh
#bash scripts/consumer.sh

