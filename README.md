# Demo files for Strimzi project

<!-- TOC depthFrom:2 -->

- [Cluster Controller](#cluster-controller)
- [Topic Controller](#topic-controller)
    - [Conflict solving and merging](#conflict-solving-and-merging)
- [Topic Webhook](#topic-webhook)

<!-- /TOC -->

## Cluster Controller

* Deploy cluster controller
```
oc apply -f cluster-controller/openshift-template.yaml
```

* Create Kafka / Zookeeper cluster
  * In openShift console
* Create Kafka Config
  * In openShift console

## Topic Controller

* Deploy Topic Controller
```
oc apply -f topic-controller/openshift-template.yaml
```

* Create topic through Kafka
```
oc exec kafka-1 -i -t -- bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --create --topic created-in-kafka --partitions 3 --replication-factor 1 --config cleanup.policy=compact
```

* Create topic through Config Map
```
oc apply -f topic-controller/topic.yaml
```

* Show how they are reconciled
```
bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --describe --topic created-as-configmap
oc get configmap created-in-kafka -o yaml
```

### Conflict solving and merging

* Shutdown topic controller
```
oc delete -f topic-controller/openshift-template.yaml
```
* Create conflicting topics
```
oc apply -f topic-controller/conflict/topic.yaml
oc exec kafka-1 -i -t -- bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --create --topic example-conflict-topic --partitions 3 --replication-factor 1 --config cleanup.policy=compact
```

* Recreate controller and let it deal with it
```
oc apply -f topic-controller/openshift-template.yaml
```

* Show how conflict resolved (Kafka wins)
```
bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --describe --topic example-conflict-topic
oc get configmap example-conflict-topic -o yaml
```

* Shutdown topic controller
```
oc delete -f topic-controller/openshift-template.yaml
```

* Re-apply topic
```
oc apply -f topic-controller/conflict/topic.yaml
```

* Recreate controller and let it deal with it
```
oc apply -f topic-controller/openshift-template.yaml
```

* Show how the changes merged and explain how the third source of truth was used
```
bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --describe --topic example-conflict-topic
oc get configmap example-conflict-topic -o yaml
```

## Topic Webhook

* Deploy Topic Webhook
```
oc apply -f topic-webhook/openshift.yaml
```

* Create producer and consumer which create topic
```
oc apply -f topic-webhook/example-consumer.yaml
oc apply -f topic-webhook/example-producer.yaml
bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --describe --topic my-webhooked-topic
```

* Show how it collaborates with the topic controller
```
oc get configmap my-webhooked-topic -o yaml
```

* Show invalid consumer and show in console how it is rejected
```
oc apply -f topic-webhook/example-rejected-consumer.yaml
```