
[ -z "$BASEDIR" ] && export BASEDIR=~
[ -z "$PACKAGEDIR" ] && export PACKAGEDIR=~
[ -z "$KAFKA_VERSION" ] && export KAFKA_VERSION=kafka_2.12-2.7.0
[ -z "$IS_SASL" ] && export IS_SASL=true
[ -z "$IS_TEST" ] && export IS_TEST=false
echo "BASEDIR: "$BASEDIR
echo "PACKAGEDIR: "$PACKAGEDIR
echo "KAFKA_VERSION: "$KAFKA_VERSION
export KAFKA_HOME=$BASEDIR/$KAFKA_VERSION

tar -zxvf $PACKAGEDIR/${KAFKA_VERSION}.tgz --directory $BASEDIR
mkdir -p $KAFKA_HOME/data/kafka
mkdir -p $KAFKA_HOME/data/zookeeper

cat >> ~/.bashrc << EOF
export KAFKA_HOME=$KAFKA_HOME
EOF

MY_HOSTNAME=$(hostname)
if [[ $MY_HOSTNAME == "kafka1" ]]; then
    export MY_ID=1
elif [[ $MY_HOSTNAME == "kafka2" ]]; then
    export MY_ID=2
elif [[ $MY_HOSTNAME == "kafka3" ]]; then
    export MY_ID=3
fi
echo "MY_ID: $MY_ID, KAFKA_HOME: $KAFKA_HOME"; 
echo "--------------------------------------------------------";


cd $KAFKA_HOME/data/zookeeper; ZOOKEEPER_DATA=`pwd`
echo $MY_ID > myid ;cat myid; sleep 3

echo "dataDir=$ZOOKEEPER_DATA
clientPort=2181
maxClientCnxns=0
initLimit=20
syncLimit=10
#admin.enableServer=false

server.1=kafka1:8888:9888
server.2=kafka2:8888:9888
server.3=kafka3:8888:9888
" > $KAFKA_HOME/config/zookeeper.properties

cd $KAFKA_HOME;
echo "$KAFKA_HOME/bin/zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties" > start-zookeeper.sh;

chmod +x start-zookeeper.sh 


#3 KAFKA
cd $KAFKA_HOME/data/kafka; KAFKA_DATA=`pwd`


BEFORE='broker.id=0'
AFTER='broker.id='$MY_ID
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE='#advertised.listeners=PLAINTEXT://your.host.name:9092'
AFTER='advertised.listeners=PLAINTEXT://'`gethostip -d $MY_HOSTNAME`':9092'
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE=/tmp/kafka-logs
AFTER=${KAFKA_DATA}
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE='offsets.topic.replication.factor=1'
AFTER='offsets.topic.replication.factor=2'
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE='transaction.state.log.replication.factor=1'
AFTER='transaction.state.log.replication.factor=2'
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE='transaction.state.log.min.isr=1'
AFTER='transaction.state.log.min.isr=2'
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties

BEFORE='zookeeper.connect=localhost:2181'
AFTER='zookeeper.connect=kafka1:2181,kafka2:2181,kafka3:2181'
sed -i "s|${BEFORE}|${AFTER}|g" $KAFKA_HOME/config/server.properties


cd $KAFKA_HOME;
echo "$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties" > start-kafka.sh;
chmod +x start-kafka.sh


if [[ $IS_SASL == "true" ]] ;then

echo "authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
requireClientAuthScheme=sasl
jaasLoginRenew=3600000
" >> $KAFKA_HOME/config/zookeeper.properties
echo "Server {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="admin"
   password="admin"
   user_admin="admin";
};
" > $KAFKA_HOME/config/zookeeper_jaas.conf
    export KAFKA_OPTS="-Djava.security.auth.login.config=$KAFKA_HOME/config/zookeeper_jaas.conf"
    $KAFKA_HOME/start-zookeeper.sh


echo 'KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin"
    user_admin="admin"
    user_alice="alice"
    user_bob="bob"
    user_charlie="charlie";
};
Client {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="admin"
   password="admin";
};' > $KAFKA_HOME/config/jaas-kafka-server.conf

echo "
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
security.inter.broker.protocol=SASL_PLAINTEXT
listeners=SASL_PLAINTEXT://:9092,PLAINTEXT://:9093
advertised.listeners=SASL_PLAINTEXT://`gethostip -d $MY_HOSTNAME`:9092,PLAINTEXT://`gethostip -d $MY_HOSTNAME`:9093

authorizer.class.name=kafka.security.authorizer.AclAuthorizer
super.users=User:admin
" >> $KAFKA_HOME/config/server.properties
    export KAFKA_OPTS="-Djava.security.auth.login.config=$KAFKA_HOME/config/jaas-kafka-server.conf"
    $KAFKA_HOME/start-kafka.sh

echo "KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin";
};
Client {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="admin";
};" > $KAFKA_HOME/config/jaas-kafka-client.conf
echo 'security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
' > ssl-user-config.properties

else
    $KAFKA_HOME/start-zookeeper.sh
    $KAFKA_HOME/start-kafka.sh
fi

export KAFKA_OPTS="-Djava.security.auth.login.config=$KAFKA_HOME/config/jaas-kafka-client.conf"
if [[ $MY_HOSTNAME == "kafka1" ]] && [[ $IS_TEST == "true" ]]; then
    $KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic test --command-config ssl-user-config.properties
    #$KAFKA_HOME/bin/kafka-topics.sh --zookeeper kafka1:2181,kafka2:2181,kafka3:2181 --create --partitions 1 --replication-factor 2 --topic test
    $KAFKA_HOME/bin/kafka-topics.sh --zookeeper kafka1:2181,kafka2:2181,kafka3:2181 --describe --command-config ssl-user-config.properties
echo "1
2
3
" > $KAFKA_HOME/sample.txt
    $KAFKA_HOME/bin/kafka-console-producer.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic test --producer.config ssl-user-config.properties < sample.txt
    $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic test --from-beginning --consumer.config ssl-user-config.properties
fi
sleep 2;
tail -f $KAFKA_HOME/logs/server.log
