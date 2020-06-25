These container images start systemd and execute the command line passed on invokation. The commandline is executed as a systemd service unit, which unfortunately means the container is non-interactive.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd.

These container images require you to pass `--privileged`. The standard execution command is as follows:

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18
```