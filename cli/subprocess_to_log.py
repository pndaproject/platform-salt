import subprocess
import select
import re
from logging import INFO


def call(cmd_to_run, logger, log_id=None, stdout_log_level=INFO, stderr_log_level=INFO, scan_for_errors=None, **kwargs):
    if scan_for_errors is None:
        scan_for_errors = []

    child_process = subprocess.Popen(cmd_to_run, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)

    log_level = {child_process.stdout: stdout_log_level, child_process.stderr: stderr_log_level}

    def fetch_child_output():
        child_output_streams = select.select([child_process.stdout, child_process.stderr], [], [], 1000)[0]
        for child_output_stream in child_output_streams:
            line = child_output_stream.readline()
            msg = line[:-1]
            msg = msg.decode('utf-8')
            if log_id is not None:
                msg_with_id = '%s %s' % (log_id, msg)
            logger.log(log_level[child_output_stream], msg_with_id)
            for pattern in scan_for_errors:
                if re.match(pattern, msg):
                    raise Exception(msg_with_id)

    while child_process.poll() is None:
        fetch_child_output()

    fetch_child_output()

    return child_process.wait()
