These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

*IMPORTANT* These container images are *NOT* compatible with Docker provided through the Snap Store due to confinement rules applied to the dockerd interfering with (preventing) our container's execution.

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
docker run --rm -it --privileged -v $PWD:/data -w /data diddledani/snapcraft:core22
```

To run with parameters, specify `snapcraft [...params]` when creating the container:

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledani/snapcraft:core22 snapcraft stage --enable-experimental-package-repositories
```

Drop to a shell with systemd running
------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledani/snapcraft:core22 bash
```

Drop to a shell without starting systemd
----------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data --entrypoint bash diddledani/snapcraft:core22
```

*Experimental* support for running through Podman
-------------------------------------------------

These containers _should_ now be compatible with Podman, but have
yet to receive much in the way of testing and validation. With the
proviso that this is highly experimental for these images, you can
try to run the build through Podman with:

```bash
sudo podman run --rm -it --privileged --systemd always -v $PWD:/data -w /data docker.io/diddledani/snapcraft:core22
```

Running through `sudo` seems to be a requirement to allow mounting
squashfs filesystems, and we still need `--privileged` the same as
when we are running through Docker. We also need to add the
`--systemd always` flag to get Podman to set up the runtime
environment appropriately for running Systemd inside the new
container instance.
