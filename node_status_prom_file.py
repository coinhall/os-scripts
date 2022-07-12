import subprocess
import json
from datetime import datetime
from pathlib import Path

HOME_PATH = Path.home()
METRICS_FILE_NAME = HOME_PATH / "node_status_file.prom"
COMMAND_PATH = HOME_PATH / Path("go/bin/")
COMMAND = COMMAND_PATH / "persistenceCore"

check_status = subprocess.run(
    [COMMAND, "status"], capture_output=True, text=True)

if check_status.returncode == 0:
    if check_status.stdout:
        print("stdout")
        parse_check_status = json.loads(check_status.stdout)
    elif check_status.stderr:
        print("stderr")
        parse_check_status = json.loads(check_status.stderr)
else:
    exit(1)

latest_block_height: str = parse_check_status["SyncInfo"]["latest_block_height"]

latest_block_time_string: str = parse_check_status["SyncInfo"]["latest_block_time"][0:23]
latest_block_time = datetime.fromisoformat(latest_block_time_string)
current_system_time = datetime.utcnow()
delta_seconds = (current_system_time - latest_block_time).total_seconds()

catching_up: bool = parse_check_status["SyncInfo"]["catching_up"]
if catching_up:
    sync_status = 1
else:
    sync_status = 0

metrics_list = ["# HELP latest_block_height The latest block height in this node.", "# TYPE latest_block_height counter", "latest_block_height %s" % latest_block_height, "# HELP delta_seconds Difference in seconds between system time and latest block time.",
                "# TYPE delta_seconds gauge", "delta_seconds %.2f" % delta_seconds, "# HELP sync_status This references the 'catching_up' boolean of the node. 0 for False and 1 for True.", "# TYPE sync_status gauge", "sync_status %d" % sync_status]

with open(METRICS_FILE_NAME, 'w') as f:
    for line in metrics_list:
        f.write(line)
        f.write('\n')
