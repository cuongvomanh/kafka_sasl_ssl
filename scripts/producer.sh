[ -z "$topic" ] && topic="test1"
[ -z "$BROKER" ] && BROKER="localhost:9092"
[ -z "$prof" ] && prof="sasl_ssl_config/producer.properties"
if [ -z "$data" ] ;then
    ./bin/kafka-console-producer.sh --broker-list $BROKER --topic $topic --producer.config=$prof
else
    echo "data: "$data
    ./bin/kafka-console-producer.sh --broker-list $BROKER --topic $topic --producer.config=$prof < $data
fi

