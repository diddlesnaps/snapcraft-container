These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd. Or you may drop to a shell with systemd running by setting the command to `bash`.

These container images require you to pass `--privileged`. The standard execution command is as follows:

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18
```

Drop to a shell with systemd running
------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18 bash
```
