These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd. Or you may drop to a shell with systemd running by setting the command to `bash`.

These container images require you to pass `--privileged`.

Running snapcraft
-----------------

Running without specifying a command will run `snapcraft` without any parameters:

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18
```

To run with parameters, specify `snapcraft [...params]` when creating the container:

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18 snapcraft stage --enable-experimental-package-repositories
```

Drop to a shell with systemd running
------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:$PWD -w $PWD diddledan/snapcraft:core18 bash
```
