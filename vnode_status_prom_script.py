#!/usr/bin/python3
# Run command to check if node is running and output certain metrics to a .prom file.
# Requires one chain specific command as argument.
# Use in conjunction with node_exporter by Prometheus
# See: https://prometheus.io/docs/guides/node-exporter/
#      https://prometheus.io/docs/instrumenting/exposition_formats/

import subprocess
import json
import sys
from datetime import datetime
from pathlib import Path

if len(sys.argv) != 2:
    print("Incorrect number of arguments. Requires one chain specific command as argument.")
    exit(1)

HOME_PATH = Path.home()
METRICS_FILE_NAME = HOME_PATH / "node-status-file.prom"
COMMAND_PATH = HOME_PATH / Path("go/bin/")

COMMAND = COMMAND_PATH / sys.argv[1]

check_status = subprocess.run(
    [COMMAND, "status"], capture_output=True, text=True)

if check_status.returncode == 0:
    is_service_up = 1

    if check_status.stdout:
        parse_check_status = json.loads(check_status.stdout)
    elif check_status.stderr:
        parse_check_status = json.loads(check_status.stderr)

    latest_block_height: str = parse_check_status["SyncInfo"]["latest_block_height"]

    latest_block_time_string: str = parse_check_status["SyncInfo"]["latest_block_time"][0:23]
    latest_block_time = datetime.fromisoformat(latest_block_time_string)
    current_system_time = datetime.utcnow()
    delta_seconds = (current_system_time - latest_block_time).total_seconds()

    latest_block_time_unix = latest_block_time.timestamp() * 1000

    catching_up: bool = parse_check_status["SyncInfo"]["catching_up"]
    if catching_up:
        sync_status = 1
    else:
        sync_status = 0

    voting_power: str = parse_check_status["ValidatorInfo"]["VotingPower"]
    if voting_power == "0":
        is_active_set = 0
    else:
        is_active_set = 1

    metrics_list = ["# HELP latest_block_height The latest block height in this node.", "# TYPE latest_block_height counter", "latest_block_height %s" % latest_block_height,
                    "# HELP delta_seconds Difference in seconds between system time and latest block time.", "# TYPE delta_seconds gauge", "delta_seconds %.2f" % delta_seconds,
                    "# HELP sync_status This references the 'catching_up' boolean of the node. 0 for False and 1 for True.", "# TYPE sync_status gauge", "sync_status %d" % sync_status,
                    "# HELP latest_block_time_unix The latest block time in this node, in unix (miliseconds).", "# TYPE latest_block_time_unix counter", "latest_block_time_unix %d" % latest_block_time_unix,
                    "# HELP is_service_up This references whether the node service is running. 0 for False and 1 for True.", "# TYPE is_service_up gauge", "is_service_up %d" % is_service_up,
                    "# HELP is_active_set This references whether the validator is in the active set. 0 for False and 1 for True.", "# TYPE is_active_set gauge", "is_active_set %d" % is_active_set]

else:
    is_service_up = 0
    metrics_list = ["# HELP is_service_up This references whether the node service is running. 0 for False and 1 for True.",
                    "# TYPE is_service_up gauge", "is_service_up %d" % is_service_up]

with open(METRICS_FILE_NAME, 'w') as f:
    for line in metrics_list:
        f.write(line)
        f.write('\n')

print(datetime.now(), "Script ran succesfully.")
