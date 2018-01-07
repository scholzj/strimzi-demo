#!/usr/bin/env bash

oc exec kafka-1 -i -t -- bin/kafka-topics.sh --zookeeper kafka-zookeeper:2181 --create --topic example-conflict-topic --partitions 3 --replication-factor 1 --config cleanup.policy=compact