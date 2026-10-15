#!/usr/bin/env bash

/usr/local/bin/docker-entrypoint.sh mysqld > /dev/null 2>&1 & disown
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-javaagent:/opt/zen/agent.jar"
