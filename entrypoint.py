#!/usr/bin/python3

import os
import sys
import shlex
import subprocess

if __name__ == "__main__":
    if sys.argv[1] == "snapcraft" or \
        sys.argv[1] == "/snap/bin/snapcraft":
        args = ["snap", "run", "snapcraft"] + sys.argv[2:]
    else:
        args = sys.argv[1:]
    commandline = " ".join([shlex.quote(a) for a in args])
    cmd = open("/docker-commandline.sh", "w")
    cmd.write("""#!/bin/bash
# trick snapcraft into thinking we're NOT a container
rm -f /.dockerenv /run/.containerenv
export SNAPCRAFT_BUILD_ENVIRONMENT=host

# set LANG so that snapcraft/python has a better environment
export LANG=C.UTF-8

echo "Starting snapd.service via systemd."
/bin/systemctl start snapd.service snapd.socket

echo "Waiting for snapd to be ready..."
snap wait system seed.loaded
echo "Snapd is now ready."

echo

echo "Installing snapcraft."
snap install snapcraft --classic

cd "{wd}"

echo
echo "Running user script: {commandline}"
{commandline}

echo "Finished. The following messages are from systemd closing down, and may be ignored."
/bin/systemctl exit $?
""".format(wd=os.getcwd(), commandline=commandline))
    cmd.close()
    os.chmod("/docker-commandline.sh", 0o755)
    os.execvp("/lib/systemd/systemd", ["/lib/systemd/systemd", "--system"])
