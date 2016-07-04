import requests
import time
import logging
import traceback

log = logging.getLogger(__name__)

def wait(name, url, expected_http_status=200, timeout=60, poll_period=1):
    attempts = 0
    try:
        while attempts * poll_period < timeout:
            log.debug('GET: %s' % url)
            r = requests.get(url)
            log.debug('GET: %s = %s' % (url, r.status_code))
            if r.status_code == expected_http_status:
                return {'result': True, 'name': name, 'comment': '', 'changes': {}}
            last_status = r.status_code
            attempts += 1
            time.sleep(poll_period)
        return {'result': False, 'name': name, 'comment': 'Giving up after %s attempts, %s never returned %s, last result was %s' % (attempts, url, expected_http_status, last_status), 'changes': {}}
    except Exception as exc:
        log.error(traceback.format_exc())
        return {'result': False, 'name': name, 'comment': str(exc), 'changes': {}}