#!/usr/bin/python3
# Run `ps -ao comm` to check current running processes.
# Requires the processes command to be passed as arguments.
# Use in conjunction with node_exporter by Prometheus
# See: https://prometheus.io/docs/guides/node-exporter/
#      https://prometheus.io/docs/instrumenting/exposition_formats/

import subprocess
import sys
from pathlib import Path
from datetime import datetime

if len(sys.argv) == 1:
    print("Requires at least one process as argument.")
    exit(1)

HOME_PATH = Path.home()
METRICS_FILE_NAME = HOME_PATH / "running-applications.prom"

sys.argv.pop(0)
wanted_processes = sys.argv

ps_process = subprocess.run(["ps", "-ao", "comm"], capture_output=True)
running_processes = ps_process.stdout.decode().split("\n")


def construct_metric(process_name, metric):
    metric_list = ["# HELP is_%s_running Whether %s is running. 0 for False, 1 for True." % (process_name, process_name), "# TYPE is_%s_running gauge" % process_name, "is_%s_running %s" % (process_name, metric)]
    return metric_list


metrics_list = []

for wanted_process in wanted_processes:
    is_running = 0 if wanted_process not in running_processes else 1
    metrics_list.extend(construct_metric(wanted_process, is_running))

with open(METRICS_FILE_NAME, 'w') as f:
    for line in metrics_list:
        f.write(line)
        f.write('\n')

print(datetime.now(), "Script ran succesfully.")
