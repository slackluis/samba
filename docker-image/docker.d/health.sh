#!/bin/bash

# Check if supervisord is running
if ! pgrep -x supervisord > /dev/null; then
  echo "FAIL: supervisord is not running"
  exit 1
fi

# Check if any process is NOT in RUNNING state
if supervisorctl status | grep -v "RUNNING" | grep -v "supervisor>" > /dev/null; then
  echo "FAIL: One or more services are not in RUNNING state"
  exit 1
fi

echo "OK: supervisord and all services are healthy"
exit 0
