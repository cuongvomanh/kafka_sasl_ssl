[ -z "$topic" ] && topic="test1"
[ -z "$BROKER" ] && BROKER="localhost:9092"
[ -z "$prof" ] && prof="sasl_ssl_config/consumer.properties"
kafka-console-consumer.sh --topic $topic --from-beginning --consumer.config=$prof  --bootstrap-server=$BROKER
