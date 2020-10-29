
https://computingforgeeks.com/run-centos-8-vm-using-vagrant-on-kvm-virtualbox-vmware-parallels/

```
VBoxManage setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0
vagrant plugin install vagrant-disksize
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-winnfsd
```
```powershell
PS C:\Windows\System32> cd 'C:\Program Files\Oracle\VirtualBox\'
PS C:\Program Files\Oracle\VirtualBox> ./VBoxManage setextradata global "VBoxInternal/NEM/UseRing0Runloop" 0
```

```
netstat -ano|findstr "2181"
tasklist|findstr "<pid>"
taskkill /T /F /PID <pid> 
```

```shell script
docker-machine create --driver virtualbox --virtualbox-memory 6000 confluent
docker-machine env confluent
docker network create confluent

# Create a Topic and Produce Data
docker run --net=confluent --rm confluentinc/cp-kafka:5.0.0 kafka-topics --create --topic foo --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181
docker run --net=confluent --rm confluentinc/cp-kafka:5.0.0 kafka-topics --describe --topic foo --zookeeper zookeeper:2181
docker run --net=confluent --rm confluentinc/cp-kafka:5.0.0 bash -c "seq 42 | kafka-console-producer --request-required-acks 1 --broker-list kafka:9092 --topic foo && echo 'Produced 42 messages.'"
docker run --net=confluent --rm confluentinc/cp-kafka:5.0.0 kafka-console-consumer --bootstrap-server kafka:9092 --topic foo --from-beginning --max-messages 42

# Schema Registry
docker run -it --net=confluent --rm confluentinc/cp-schema-registry:5.0.0 bash
/usr/bin/kafka-avro-console-producer --broker-list kafka:9092 --topic bar --property schema.registry.url=http://schema-registry:8081 --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'
# Enter these messages:
{"f1": "value1"}
{"f1": "value2"}
{"f1": "value3"}

# REST Proxy
docker run -it --net=confluent --rm confluentinc/cp-schema-registry:5.0.0 bash
curl -X POST -H "Content-Type: application/vnd.kafka.v1+json" --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "smallest"}' http://kafka-rest:8082/consumers/my_avro_consumer
curl -X GET -H "Accept: application/vnd.kafka.avro.v1+json" http://kafka-rest:8082/consumers/my_avro_consumer/instances/my_consumer_instance/topics/bar

# Control Center
docker logs control-center | grep Started

docker run \
  --net=confluent \
  --rm confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic c3-test --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

while true;
do
  docker run \
    --net=confluent \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.0.jar \
    confluentinc/cp-kafka-connect:5.0.0 \
    bash -c 'seq 10000 | kafka-console-producer --request-required-acks 1 --broker-list kafka:9092 --topic c3-test --producer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor --producer-property acks=1 && echo "Produced 10000 messages."'
    sleep 10;
done
```
```shell script
OFFSET=0
while true;
do
  docker run \
    --net=confluent \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.0.jar \
    confluentinc/cp-kafka-connect:5.0.0 \
    bash -c 'kafka-console-consumer --consumer-property group.id=qs-consumer --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor --bootstrap-server kafka:9092 --topic c3-test --offset '$OFFSET' --partition 0 --max-messages=1000'
  sleep 1;
  let OFFSET=OFFSET+1000
done
```

```shell script
# Kafka Connect
docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic quickstart-offsets --partitions 1 \
  --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic quickstart-data --partitions 1 \
  --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

docker run \
   --net=confluent \
   --rm \
   confluentinc/cp-kafka:5.0.0 \
   kafka-topics --describe --zookeeper zookeeper:2181

docker-compose -f docker-compose-kafka-connect.yaml up -d

docker logs kafka-connect | grep started

docker exec kafka-connect mkdir -p /tmp/quickstart/file
```
