#!/bin/bash
# Raises OS file limits and available port ranges according to https://socket.io/docs/v4/performance-tuning/#at-the-os-level.

set -e

target_ulimit=1048576
current_soft_file_limit=$(ulimit -n)
current_hard_file_limit=$(ulimit -Hn)
limit_file_path="/etc/security/limits.d/custom.conf"
limit_file_content="* soft nofile $target_ulimit
* hard nofile $target_ulimit"

target_lower_port_range=10000
target_upper_port_range=65535
port_range=($(cat /proc/sys/net/ipv4/ip_local_port_range))
current_lower_port_range=${port_range[0]}
current_upper_port_range=${port_range[1]}
port_file_path="/etc/sysctl.d/net.ipv4.ip_local_port_range.conf"
port_file_content="net.ipv4.ip_local_port_range = $target_lower_port_range $target_upper_port_range"

reboot_required=false

# configure file limits
if [ $current_soft_file_limit -eq $target_ulimit ] && [ $current_hard_file_limit -eq $target_ulimit ]; then
  echo "File limit already match target limit of $target_ulimit."
else
  echo "$limit_file_content" >$limit_file_path
  echo "File limit of $target_ulimit written to $limit_file_path"
  reboot_required=true
fi

# configure available port ranges
if [ $current_lower_port_range -eq $target_lower_port_range ] && [ $current_upper_port_range -eq $target_upper_port_range ]; then
  echo "Port range already match target range of $target_lower_port_range to $target_upper_port_range."
else
  echo "$port_file_content" >$port_file_path
  echo "Port range of $target_lower_port_range to $target_upper_port_range written to $port_file_path"
  reboot_required=true
fi

if [ $reboot_required == false ]; then
  exit 0
fi

# prompt reboot if necessary
echo
echo "SYSTEM REBOOT REQUIRED! REBOOT NOW WITH:"
echo "sudo shutdown -r now"
