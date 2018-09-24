#!/bin/bash
redis_root=../redis
redis_server=$redis_root/src/redis-server
redis_config=$redis_root/redis.conf
$redis_server $redis_config
