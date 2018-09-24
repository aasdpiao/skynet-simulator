#!/bin/bash
redis_root=../redis
config_root=../config
redis_server=$redis_root/src/redis-server
redis_config=$config_root/redis.conf
$redis_server $redis_config
