These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd. Or you may drop to a shell with systemd running by setting the command to `bash`.

These container images require you to pass `--privileged`.

Notes
-----
For builds against `core` the version of Systemd included in Ubuntu Xenial, and thus included in the `core` container images, is not compatible with cgroups version 2. This causes the `core` container image to fail to finish starting on newer distros. On systems that use cgroups2 you might _still_ be able to run the `core` container images by adding `--tmpfs /sys/fs/cgroup` to the docker or podman command line.

Previous instructions, based on earlier iterations of the container images, required you to create
and use an AppArmor namespace - this is not necessary any more.  That is, you no-longer need to create a separate AppArmor namespace directory at
`/sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft` and you can drop the
`--security-opt apparmor=":docker-snapcraft:unconfined"` parameter from your `docker` command line.

Running snapcraft
-----------------

Running without specifying a command will run `snapcraft` without any parameters:

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core22
```

To run with parameters, specify `snapcraft [...params]` when creating the container:

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core22 snapcraft stage --enable-experimental-package-repositories
```

Drop to a shell with systemd running
------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core22 bash
```

Drop to a shell without starting systemd
----------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data --entrypoint bash diddledan/snapcraft:core22
```
