#!/bin/bash
# Configures OS to ensure optimal tuning for ClickHouse.
# Script is idempotent and can be run multiple times to update ClickHouse if needed.
# Requires root access: run script with `sudo`!
# See: https://clickhouse.com/docs/en/operations/tips/
#      https://anthonynsimon.com/blog/clickhouse-deployment/

set -e

# Use "performance" scaling governor
scaling_gov_file=/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
if [ -f $scaling_gov_file ]; then
  echo "performance" >$scaling_gov_file
else
  echo "$scaling_gov_file not found; scaling governor not set!"
fi
# Enable memory overcommit
echo 0 >/proc/sys/vm/overcommit_memory
# Raise file limits
target_ulimit=1048576
limit_file_path="/etc/security/limits.d/custom.conf"
limit_file_content="* soft nofile $target_ulimit
* hard nofile $target_ulimit"
echo "$limit_file_content" >$limit_file_path
echo "File limit of $target_ulimit written to $limit_file_path"
# Reduce usage of swap files
echo "vm.swappiness=1" >/etc/sysctl.conf
# Log completion
echo "OS configurations successfully updated!"

# Install ClickHouse
# See: https://clickhouse.com/docs/en/install#install-from-deb-packages
echo "Installing ClickHouse..."
sudo apt-get install -y apt-transport-https ca-certificates dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8919F6BD2B48D754
echo "deb https://packages.clickhouse.com/deb stable main" >/etc/apt/sources.list.d/clickhouse.list
sudo apt-get update
sudo apt-get install -y clickhouse-server clickhouse-client
sudo service clickhouse-server start
echo "ClickHouse successfully installed!"

# Prompt reboot
echo
echo "Setup script done!"
echo "SYSTEM REBOOT REQUIRED! REBOOT NOW WITH:"
echo "sudo shutdown -r now"
