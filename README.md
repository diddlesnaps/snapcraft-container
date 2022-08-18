These container images start systemd and execute the command line passed on invokation. The commandline is executed as an interactive systemd service unit.

*IMPORTANT* These container images are *NOT* compatible with Docker provided through the Snap Store due to confinement rules applied to the dockerd interfering with (preventing) our container's execution.

You may override the entrypoint with the `--entrypoint` parameter if you need to run the container without starting systemd. Or you may drop to a shell with systemd running by setting the command to `bash`.

These container images require you to pass `--privileged`.

Note
----
Currently there is an issue with the combination of Core20 and running this image through qemu emulating ARMv7, such as when running on GitHub Actions. See [the bug on Launchpad.net](https://bugs.launchpad.net/qemu/+bug/1886811) for the root cause.

Previous instructions, based on earlier iterations of the container images, required you to create
and use an AppArmor namespace - this is not necessary any more.  That is, you no-longer need to create a separate AppArmor namespace directory at
`/sys/kernel/security/apparmor/policy/namespaces/docker-snapcraft` and you can drop the
`--security-opt apparmor=":docker-snapcraft:unconfined"` parameter from your `docker` command line.

Running snapcraft
-----------------

Running without specifying a command will run `snapcraft` without any parameters:

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core18
```

To run with parameters, specify `snapcraft [...params]` when creating the container:

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core18 snapcraft stage --enable-experimental-package-repositories
```

Drop to a shell with systemd running
------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data diddledan/snapcraft:core18 bash
```

Drop to a shell without starting systemd
----------------------------------------

```bash
docker run --rm -it --privileged -v $PWD:/data -w /data --entrypoint bash diddledan/snapcraft:core18
```
