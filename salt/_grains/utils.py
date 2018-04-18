#!/usr/bin/env python
"""
Get some grains informations which could be used by services
"""

import subprocess

def _public_ip():

    publicip_script = subprocess.Popen(['/etc/pnda/public_ip.sh'], stdout=subprocess.PIPE)
    out, err = publicip_script.communicate(str.encode("utf-8"))
    if err == None:
        return {'public_ip': out}
    else:
        return {'public_ip': ''}

def main():
    grains = _public_ip()
    return grains