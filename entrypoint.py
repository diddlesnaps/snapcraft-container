#!/usr/bin/python3

import os
import sys
import time
import subprocess

if __name__ == "__main__":
        cmd = open("/docker-commandline.sh", "w")
        cmd.write("""#!/bin/bash
/bin/systemctl start snapd.service snapd.socket
/bin/retry.py --quiet -n 60 --wait 5 sh -c 'snap changes | grep -q "Done.*Initialize system state"'
snap install snapcraft --classic

cd {wd}
{commandline}

/bin/systemctl exit $?
""".format(wd=os.getcwd(), commandline=" ".join(sys.argv[1:])))
        cmd.close()
        os.chmod("/docker-commandline.sh", 0o755)
        os.execvp("/lib/systemd/systemd", ["/lib/systemd/systemd", "--system"])
