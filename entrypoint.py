#!/usr/bin/python3

import os
import sys
import shlex
import subprocess

if __name__ == "__main__":
        commandline = " ".join([shlex.quote(a) for a in sys.argv[1:]])
        cmd = open("/docker-commandline.sh", "w")
        cmd.write("""#!/bin/bash
/bin/systemctl start snapd.service snapd.socket
/bin/retry.py --quiet -n 60 --wait 5 sh -c 'snap changes | grep -q "Done.*Initialize system state"'
snap install snapcraft --classic

cd "{wd}"
{commandline}

/bin/systemctl exit $?
""".format(wd=os.getcwd(), commandline=commandline))
        cmd.close()
        os.chmod("/docker-commandline.sh", 0o755)
        os.execvp("/lib/systemd/systemd", ["/lib/systemd/systemd", "--system"])
