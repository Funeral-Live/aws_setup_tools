#!/bin/bash

ps aux | grep "${1}" | awk '{print $2}' | xargs kill -9 $3
