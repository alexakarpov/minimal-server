#!/bin/sh
docker container run -d -p 8080:15672 -p 5672:5672 --name some-rabbit rabbitmq:3-management
